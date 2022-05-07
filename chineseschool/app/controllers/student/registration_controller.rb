class Student::RegistrationController < ApplicationController

  #verify :only => [:save_registration_preferences, :payment_entry, :submit_payment] , :method => :post,
  #    :add_flash => {:notice => 'Illegal GET'}, :redirect_to => {:controller => '/signout', :action => 'index'}

  def display_options
    @registration_school_year = SchoolYear.find params[:id].to_i
    @register_elective_class_only = params[:register_elective_class_only]
    @previous_school_year = @registration_school_year.previous_school_year
    create_registration_preferences_for_display_optioins
  end

  def save_registration_preferences
    @registration_school_year = SchoolYear.find params[:id].to_i
    @register_elective_class_only = params[:register_elective_class_only]
    @registration_preferences = save_registration_preferences_from_params
    if @registration_preferences.empty?
      if @register_elective_class_only == 'Y'
        flash[:notice] = 'No student or no elective class selected for registration!!'
      else
        flash[:notice] = 'No student selected for registration!!'
      end
      redirect_to action: :display_options, id: @registration_school_year, register_elective_class_only: @register_elective_class_only
    else
      @student_names = @registration_preferences.collect do |registration_preference|
        registration_preference.student.name
      end.join(', ')
    end
  end

  def payment_entry
    @registration_school_year = SchoolYear.find params[:id].to_i
    @register_elective_class_only = params[:register_elective_class_only]
    @registration_preference_ids = params[:registration_preferences].values
    if @registration_preference_ids.nil? or @registration_preference_ids.empty?
      flash[:notice] = 'No student selected for registration!!'
      redirect_to(action: :display_options, id: @registration_school_year, register_elective_class_only: @register_elective_class_only) and return
    end

    @credit_card = CreditCard.new
    if @register_elective_class_only == 'Y'
      render(template: '/student/registration/payment_entry_elective_class') and return
    else
      @registration_payment = create_and_save_registration_payment @registration_preference_ids, @registration_school_year
    end
  end

  def remove_pending_registration_payment
    registration_payment = RegistrationPayment.find params[:id].to_i
    if registration_payment.nil?
      logger.warn "Could not find registration payment with id => #{params[:id]}"
    else
      remove_incomplete registration_payment
    end
    redirect_to controller: '/home'
  end

  def submit_payment
    @register_elective_class_only = params[:register_elective_class_only]
    # register_elective_class_only process
    if @register_elective_class_only == 'Y'
      @credit_card = CreditCard.new params[:credit_card]
      @registration_preference_ids = params[:registration_preference_ids].values
      @gateway_transactions = []
      @registration_school_year = SchoolYear.find_by_id params[:registration_school_year].to_i
      cc_transaction_approved_count = 0
      if @registration_preference_ids.nil? or @registration_preference_ids.empty?
        flash[:notice] = 'No registration preference found!'
        render(template: '/student/registration/payment_entry_elective_class') and return
      end
      unless @credit_card.valid?
        render(template: '/student/registration/payment_entry_elective_class') and return
      end

      @registration_preference_ids.each do |registration_preference_id|
        registration_preference = RegistrationPreference.find registration_preference_id
        student_status_flag = registration_preference.student.student_status_flag_for @registration_school_year
        # each registration_preference_id may has its own registration_payment
        if (not student_status_flag.nil?) and student_status_flag.registered?
          paid_student_fee_payment = registration_preference.student.find_paid_student_fee_payment_as_student_for(@registration_school_year)
          registration_payment = paid_student_fee_payment.registration_payment
          gateway_transaction = GatewayTransaction.new
          gateway_transaction.registration_payment = registration_payment
          gateway_transaction.amount_in_cents = @registration_school_year.elective_class_fee_in_cents
          gateway_transaction.credit_card_type = @credit_card.type
          gateway_transaction.credit_card_last_digits = @credit_card.last_digits
          gateway_transaction.save!

          begin
            #response = ::LINKPOINT_GATEWAY.purchase(gateway_transaction.amount_in_cents, @credit_card, order_id: gateway_transaction.id)
            response = ::AUTHORIZE_NET_GATEWAY.purchase(gateway_transaction.amount_in_cents, @credit_card, order_id: gateway_transaction.id)
            save_gateway_response gateway_transaction, response
          rescue => e
            gateway_transaction.error_message = e.inspect
            gateway_transaction.save!
            flash.now[:notice] = "Error occurred when processing payment for " + registration_preference.student.name + ", Please try again later or contact #{Contacts::WEB_SITE_SUPPORT}"
            render(template: '/student/registration/payment_entry_elective_class') and return
          end

          if GatewayTransaction::APPROVAL_STATUS_APPROVED == gateway_transaction.approval_status
            cc_transaction_approved_count = cc_transaction_approved_count + 1
            paid_student_fee_payment.elective_class_fee_in_cents = gateway_transaction.amount_in_cents
            paid_student_fee_payment.save!

            registration_payment.grand_total_in_cents = registration_payment.grand_total_in_cents + gateway_transaction.amount_in_cents
            registration_payment.save!

            # set the elective_class from temp column
            registration_preference.elective_class = registration_preference.re_register_elective_class
            registration_preference.save!

            # update student_class_assignment.elective_class to selected elective class
            student_class_assignment = student_class_assignment_for @registration_school_year
            unless student_class_assignment.nil?
              student_class_assignment.elective_class = registration_preference.elective_class
            end
            registration_payment.send_email_notification(gateway_transaction, 'Y', registration_preference_id)
            @gateway_transactions << gateway_transaction
          else
            flash.now[:notice] = "Payment DECLINED by bank when processing for " + registration_preference.student.name + ". Please use a different credit card to try again or contact #{Contacts::WEB_SITE_SUPPORT}"
            if GatewayTransaction::APPROVAL_STATUS_ERROR == gateway_transaction.approval_status
              send_email_to_engineering_for_unexpected_transaction_error(gateway_transaction)
            end
            render template: '/student/registration/payment_entry_elective_class' and return
          end
        end
      end
      # all transactions are approved
      if cc_transaction_approved_count > 0 and cc_transaction_approved_count == @registration_preference_ids.size
        render template: '/student/registration/payment_confirmation_elective_class' and return
      else
        flash.now[:notice] = "Not all registration payments have been processed. Please check your registration status and try again or contact #{Contacts::WEB_SITE_SUPPORT}"
        redirect_to(controller: '/home') and return
      end
      # non register_elective_class_only process
    else
      @registration_payment = RegistrationPayment.find params[:id].to_i
      if @registration_payment.paid?
        redirect_to(action: :payment_confirmation, id: @registration_payment) and return
      end
      if @registration_payment.at_least_one_student_already_registered?
        flash[:notice] = 'At least one student in the attempted payment has already registered.'
        redirect_to(action: :display_options, id: @registration_payment.school_year) and return
      end
      @credit_card = CreditCard.new params[:credit_card]
      unless @credit_card.valid?
        render(template: '/student/registration/payment_entry') and return
      end
      gateway_transaction = create_and_save_initial_gateway_transaction
      begin
        #response = ::LINKPOINT_GATEWAY.purchase(gateway_transaction.amount_in_cents, @credit_card, order_id: gateway_transaction.id)
        response = ::AUTHORIZE_NET_GATEWAY.purchase(gateway_transaction.amount_in_cents, @credit_card, order_id: gateway_transaction.id)
        save_gateway_response gateway_transaction, response
      rescue => e
        gateway_transaction.error_message = e.inspect
        gateway_transaction.save!
        flash.now[:notice] = "Error occurred when processing payment.  Please try again later or contact #{Contacts::WEB_SITE_SUPPORT}"
        render(template: '/student/registration/payment_entry') and return
      end

      if GatewayTransaction::APPROVAL_STATUS_APPROVED == gateway_transaction.approval_status
        @registration_payment.paid = true
        @registration_payment.save!
        begin
          @registration_payment.create_student_class_assignments
          @registration_payment.send_email_notification(gateway_transaction,'N', nil)
        rescue => e
          logger.error "Error during post-payment operations => #{e.inspect}"
        end
        redirect_to action: :payment_confirmation, id: @registration_payment
      else
        flash.now[:notice] = "Payment DECLINED by bank.  Please use a different credit card to try again or contact #{Contacts::WEB_SITE_SUPPORT}"
        if GatewayTransaction::APPROVAL_STATUS_ERROR == gateway_transaction.approval_status
          send_email_to_engineering_for_unexpected_transaction_error(gateway_transaction)
        end
        render template: '/student/registration/payment_entry'
      end
    end
  end

  def payment_confirmation
    @registration_payment = RegistrationPayment.find params[:id].to_i
    unless @registration_payment.paid_by == @user.person
      flash[:notice] = 'Access to requested payment confirmation not authorized'
      redirect_to(controller: '/home') and return
    end
    @gateway_transaction = @registration_payment.find_first_approved_gateway_transaction
  end

  def request_in_person_payment
    @registration_payment = RegistrationPayment.find params[:id].to_i
    @registration_payment.request_in_person = TRUE
    @registration_payment.save!
  end

  private

  def create_registration_preferences_for_display_optioins
    @registered_students = []
    @registration_preferences = []
    find_possible_students.each do |student|
      student_status_flag = student.student_status_flag_for @registration_school_year
      if (not student_status_flag.nil?) and student_status_flag.registered?
        @registered_students << student
      else
        # New registration preferences created here are not saved
        # they are only used to help rendering display options view
        new_registration_preference = RegistrationPreference.new
        new_registration_preference.school_year = @registration_school_year
        new_registration_preference.student = student
        previous_school_year_class_assignment = student.student_class_assignment_for @registration_school_year.previous_school_year
        if previous_school_year_class_assignment.nil?
          # No class assignment in the previous school year - go for age-based grade assignment
          age_based_grade = Grade.find_by_school_age(student.school_age_for(@registration_school_year))
          unless age_based_grade.nil?
            new_registration_preference.grade = age_based_grade.snap_down_to_first_active_grade @registration_school_year
            @registration_preferences << new_registration_preference
          end
          # If age-based grade is nil, it means the student is either too young or too old - don't add to list
        else
          # Grade assignment based on previous school year
          new_registration_preference.previous_grade = previous_school_year_class_assignment.grade
          new_registration_preference.grade = new_registration_preference.previous_grade.next_grade.snap_down_to_first_active_grade @registration_school_year
          @registration_preferences << new_registration_preference
        end
      end
    end
  end

  def save_registration_preferences_from_params
    registration_preferences = []
    find_possible_students.each do |student|
      student_register_elective_class_flag = params["#{student.id}_register_elective".to_sym]
      if (!student_register_elective_class_flag.nil?) && (student_register_elective_class_flag == "true")
        registration_preference = find_or_create_registration_preference_for student
        registration_preference.re_register_elective_class_id = extract_elective_class_id_from_params student.id
        if !registration_preference.re_register_elective_class_id.nil? && registration_preference.re_register_elective_class_id > 0 && registration_preference.save
          registration_preferences << registration_preference
        end
      end

      student_register_flag = params["#{student.id}_register".to_sym]
      if (!student_register_flag.nil?) && (student_register_flag == "true")
        registration_preference = find_or_create_registration_preference_for student
        registration_preference.previous_grade_id = extract_previous_grade_id_from_params student.id
        registration_preference.grade_id = extract_grade_id_from_params student.id
        registration_preference.school_class_type = params["#{student.id}_school_class_type".to_sym]
        registration_preference.elective_class_id = extract_elective_class_id_from_params student.id
        if registration_preference.save
          registration_preferences << registration_preference
        end
      end
    end
    registration_preferences
  end

  def find_or_create_registration_preference_for(student)
    registration_preference = RegistrationPreference.first conditions: ['school_year_id = ? AND student_id = ?', @registration_school_year.id, student.id]
    if registration_preference.nil?
      registration_preference = RegistrationPreference.new
      registration_preference.school_year = @registration_school_year
      registration_preference.student = student
    end
    registration_preference.entered_by = @user.person
    registration_preference
  end

  def extract_previous_grade_id_from_params(student_id)
    previous_grade_id = params["#{student_id}_previous_grade".to_sym]
    return nil if previous_grade_id.blank?
    previous_grade_id.to_i
  end

  def extract_grade_id_from_params(student_id)
    grade_id = params["#{student_id}_grade".to_sym]
    return nil if grade_id.blank?
    grade_id.to_i
  end

  def extract_elective_class_id_from_params(student_id)
    elective_class_hash = params["#{student_id}_elective".to_sym]
    return nil if elective_class_hash.nil?
    elective_class_id = elective_class_hash[:elective_class]
    return nil if elective_class_id.blank?
    elective_class_id.to_i
  end

  def create_and_save_registration_payment(registration_preference_ids, registration_school_year)
    # calculations here must be done in a specific order because
    # later calculations may depends on the result of earlier calculations
    remove_previously_pending_registration_payments @user.person, registration_school_year
    paid_student_fee_payments_in_family = find_paid_student_fee_payments_in_family_for registration_school_year
    registration_payment = RegistrationPayment.new
    registration_payment.school_year = registration_school_year
    registration_payment.paid_by = @user.person
    registration_preference_ids.each do |registration_preference_id|
      registration_preference = RegistrationPreference.find registration_preference_id
      student_fee_payment = StudentFeePayment.new
      student_fee_payment.student = registration_preference.student
      student_fee_payment.fill_in_tuition_and_fee registration_school_year, registration_preference.grade, registration_preference.elective_class, (paid_student_fee_payments_in_family + registration_payment.student_fee_payments)
      student_fee_payment.registration_payment = registration_payment
      registration_payment.student_fee_payments << student_fee_payment
    end
    registration_payment.fill_in_due paid_student_fee_payments_in_family.size
    registration_payment.calculate_grand_total
    registration_payment.save!
    registration_payment
  end

  def remove_previously_pending_registration_payments(paid_by, school_year)
    #RegistrationPayment.find_pending_payments_for paid_by, school_year
    # TODO - delay the implementation due to complications with multiple possible paid_by and
    # multiple possible student combinations
  end

  def remove_incomplete(registration_payment)
    if registration_payment.paid? or (not registration_payment.gateway_transactions.empty?)
      logger.warn "Attempting to remove a processed registration #{registration_payment.id} by user #{@user.id}"
    else
      registration_payment.destroy
    end
  end

  def find_paid_student_fee_payments_in_family_for(school_year)
    paid_student_fee_payments = []
    find_possible_students.each do |student|
      student_status_flag = student.student_status_flag_for school_year
      if (not student_status_flag.nil?) and student_status_flag.registered?
        paid_student_fee_payment = student.find_paid_student_fee_payment_as_student_for(school_year)
        if paid_student_fee_payment.nil?
          logger.error "Unable to find paid student fee payment for registered student => #{student.id}"
        else
          paid_student_fee_payments << paid_student_fee_payment
        end
      end
    end
    paid_student_fee_payments
  end

  def create_and_save_initial_gateway_transaction
    gateway_transaction = GatewayTransaction.new
    gateway_transaction.registration_payment = @registration_payment
    gateway_transaction.amount_in_cents = @registration_payment.grand_total_in_cents
    gateway_transaction.credit_card_type = @credit_card.type
    gateway_transaction.credit_card_last_digits = @credit_card.last_digits
    gateway_transaction.save!
    gateway_transaction
  end

  def save_gateway_response(gateway_transaction, response)
    gateway_transaction.set_approval_status_based_on_authorize_net_response(response.params['response_code'])
    gateway_transaction.response_dump = response.inspect
    if response.success?
      gateway_transaction.approval_code = response.params['authorization_code']
      gateway_transaction.reference_number = response.params['transaction_id']
    else
      gateway_transaction.error_message = response.message
    end
    gateway_transaction.save!
  end

  # this is a backup copy of linkpoint gateway response parsing - not in active use if the live gateway is Authorize.Net
  # TODO - remove this method after TOCS disabled the old linkpoint gateway
  def save_gateway_response_for_linkpoint(gateway_transaction, response)
    gateway_transaction.approval_status = response.params['approved']
    gateway_transaction.response_dump = response.inspect
    if response.success?
      gateway_transaction.approval_code = response.params['code']
      gateway_transaction.reference_number = response.params['ref']
    else
      gateway_transaction.error_message = response.params['error']
    end
    gateway_transaction.save!
  end

  def send_email_to_engineering_for_unexpected_transaction_error(gateway_transaction)
    begin
      OpsMailer.credit_card_transaction_error_alert(gateway_transaction).deliver
    rescue => e
      logger.error "Error sending email to engineering => #{e.inspect}"
    end
  end

  def find_registered_students(registration_school_year)
    registered_students = []
    find_possible_students.each do |student|
      student_status_flag = student.student_status_flag_for registration_school_year
      if (not student_status_flag.nil? and student_status_flag.registered?)
        registered_students << student
      end
    end
    registered_students
  end

end
