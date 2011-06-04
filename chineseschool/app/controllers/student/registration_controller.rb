class Student::RegistrationController < ApplicationController

  verify :only => [:save_registration_preferences, :payment_entry, :submit_payment] , :method => :post,
      :add_flash => {:notice => 'Illegal GET'}, :redirect_to => {:controller => '/signout', :action => 'index'}
  
  def display_options
    @registration_school_year = SchoolYear.find_by_id params[:id].to_i
    @previous_school_year = @registration_school_year.previous_school_year
    @registration_preferences = create_registration_preferences_for_display_optioins
  end
  
  def save_registration_preferences
    @registration_school_year = SchoolYear.find_by_id params[:id].to_i
    @registration_preferences = save_registration_preferences_from_params
    if @registration_preferences.empty?
      flash[:notice] = 'No student selected for registration!!'
      redirect_to :action => :display_options, :id => @registration_school_year
    else
      @student_names = @registration_preferences.collect do |registration_preference|
        registration_preference.student.name
      end.join(', ')
    end
  end

  def payment_entry
    registration_school_year = SchoolYear.find_by_id params[:id].to_i
    registration_preference_ids = params[:registration_preferences].values
    if registration_preference_ids.nil? or registration_preference_ids.empty?
      flash[:notice] = 'No student selected for registration!!'
      redirect_to(:action => :display_options, :id => registration_school_year.id) and return
    end
    @registration_payment = create_and_save_registration_payment registration_preference_ids, registration_school_year
    @credit_card = CreditCard.new
  end
  
  def remove_pending_registration_payment
    registration_payment = RegistrationPayment.find_by_id params[:id].to_i
    if registration_payment.nil?
      logger.warn "Could not find registration payment with id => #{params[:id]}"
    else
      if registration_payment.paid? or (not registration_payment.gateway_transactions.empty?)
        logger.warn "Attempting to remove a processed registration #{registration_payment.id} by user #{@user.id}"
      else
        registration_payment.destroy
      end
    end
    redirect_to :controller => '/home', :action => 'index'
  end

  def submit_payment
    @registration_payment = RegistrationPayment.find_by_id params[:id].to_i
    if @registration_payment.paid?
      redirect_to(:action => :payment_confirmation, :id => @registration_payment) and return
    end
    @credit_card = CreditCard.new params[:credit_card]
    unless @credit_card.valid?
      render :template => '/student/registration/payment_entry' and return
    end
    gateway_transaction = create_and_save_initial_gateway_transaction
    begin
      #response = ::LINKPOINT_GATEWAY.purchase(gateway_transaction.amount_in_cents, @credit_card, :order_id => gateway_transaction.id)
      #save_gateway_response gateway_transaction, response
      fake_response_for_testing_offline gateway_transaction
    rescue => e
      gateway_transaction.error_message = e.inspect
      gateway_transaction.save!
      flash.now[:notice] = "Error occurred when processing payment.  Please try again later or contact #{Contacts::WEB_SITE_SUPPORT}"
      render :template => '/student/registration/payment_entry' and return
    end

    if GatewayTransaction::APPROVAL_STATUS_APPROVED == gateway_transaction.approval_status
      @registration_payment.paid = true
      @registration_payment.save!
      #create_student_class_assignments
      redirect_to :action => :payment_confirmation, :id => @registration_payment
    else
      flash.now[:notice] = "Payment DECLINED by bank.  Please use a different credit card to try again or contact #{Contacts::WEB_SITE_SUPPORT}"
      render :template => '/student/registration/payment_entry'
    end
  end

  def payment_confirmation
    @registration_payment = RegistrationPayment.find_by_id params[:id].to_i
    @gateway_transaction = @registration_payment.find_first_approved_gateway_transaction
  end

  private

  def create_registration_preferences_for_display_optioins
    # Registration preferences created here are not saved - only used to help rendering display options view
    registration_preferences = []
    find_possible_students.each do |student|
      registration_preference = RegistrationPreference.new
      registration_preference.student = student
      previous_school_year_class_assignment = student.student_class_assignment_for @registration_school_year.previous_school_year
      if previous_school_year_class_assignment.nil?
        # No class assignment in the previous school year - go for age-based grade assignment
        age_based_grade = Grade.find_by_school_age(student.school_age_for(@registration_school_year))
        unless age_based_grade.nil?
          registration_preference.grade = age_based_grade.snap_down_to_first_active_grade @registration_school_year
          registration_preferences << registration_preference
        end
        # If age-based grade is nil, it means the student is either too young or too old - don't add to list
      else
        # Grade assignment based on previous school year
        registration_preference.previous_grade = previous_school_year_class_assignment.grade
        registration_preference.grade = registration_preference.previous_grade.next_grade.snap_down_to_first_active_grade @registration_school_year
        registration_preferences << registration_preference
      end
    end
    registration_preferences
  end
  
  def save_registration_preferences_from_params
    registration_preferences = []
    find_possible_students.each do |student|
      student_register_flag = params["#{student.id}_register".to_sym]
      if (!student_register_flag.nil?) and (student_register_flag == "true")
        registration_preference = find_or_create_registration_preference_for student
        registration_preference.previous_grade_id = extract_previous_grade_id_from_params student.id
        registration_preference.grade_id = extract_grade_id_from_params student.id
        registration_preference.school_class_type = params["#{student.id}_school_class_type".to_sym][:school_class_type]
        registration_preference.elective_class_id = extract_elective_class_id_from_params student.id
        if registration_preference.save
          registration_preferences << registration_preference
        end
      end
    end
    registration_preferences
  end

  def find_or_create_registration_preference_for(student)
    registration_preference = RegistrationPreference.first :conditions => ['school_year_id = ? AND student_id = ?', @registration_school_year.id, student.id]
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
    registration_payment = RegistrationPayment.new
    registration_payment.school_year = registration_school_year
    registration_payment.paid_by = @user.person
    registration_preference_ids.each do |registration_preference_id|
      registration_preference = RegistrationPreference.find_by_id registration_preference_id
      student_fee_payment = StudentFeePayment.new
      student_fee_payment.student = registration_preference.student
      student_fee_payment.fill_in_tuition_and_fee registration_school_year, registration_preference.grade, registration_payment.student_fee_payments.size
      student_fee_payment.registration_payment = registration_payment
      registration_payment.student_fee_payments << student_fee_payment
    end
    registration_payment.fill_in_due
    registration_payment.calculate_grand_total
    registration_payment.save!
    registration_payment
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
    gateway_transaction.approval_status = response.params[:approved]
    gateway_transaction.response_dump = response.inspect
    if response.success
      gateway_transaction.approval_code = response.params[:code]
      gateway_transaction.reference_number = response.params[:ref]
    else
      gateway_transaction.error_message = response.params[:error]
    end
    gateway_transaction.save!
  end

  def fake_response_for_testing_offline(gateway_transaction)
    gateway_transaction.approval_status = GatewayTransaction::APPROVAL_STATUS_APPROVED
    gateway_transaction.response_dump = 'Fake response for offline tests'
    gateway_transaction.approval_code = 'Fake Code'
    gateway_transaction.reference_number = 'Fake Ref Number'
    gateway_transaction.save!
  end
end
