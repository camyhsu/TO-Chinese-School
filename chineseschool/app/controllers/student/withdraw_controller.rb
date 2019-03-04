class Student::WithdrawController < ApplicationController

  def withdraw_entry
    @registration_school_year = SchoolYear.find params[:id].to_i
    @paid_students = []
    find_possible_students.each do |student|
      paid_student_fee_payment = student.find_paid_student_fee_payment_as_student_for(@registration_school_year)
      withdraw_request = student.find_withdraw_request_for(@registration_school_year)
      if !paid_student_fee_payment.nil? && withdraw_request.nil?
        @paid_students << student
      end
    end
  end

  def refund_detail_preview
    registration_school_year = SchoolYear.find params[:id].to_i
    withdraw_student_count = 0
    find_possible_students.each do |student|
      selected_withdraw_student = params["#{student.id}_withdraw".to_sym]
      if (!selected_withdraw_student.nil? && selected_withdraw_student == "1")
        paid_student_fee_payment = student.find_paid_student_fee_payment_as_student_for(registration_school_year)
        unless paid_student_fee_payment.nil?
          withdraw_student_count += 1
        end
      end
    end
    if withdraw_student_count == 0
      flash[:notice] = 'No student selected or no fee payment found for selected student!'
      redirect_to(action: :withdraw_entry, id: registration_school_year) and return
    end
    @withdraw_request = init_withdraw_request
  end

  def save_withdraw_request
    withdraw_request = WithdrawRequest.new(params[:withdraw_request])
    withdraw_request.withdraw_request_details = get_withdraw_request_details_from_params
    unless withdraw_request.save
      flash.now[:notice] = "Error happens when save the record. Please try again later or contact us at #{Contacts::REGISTRATION_CONTACT}."
      return
    end
    WithdrawalMailer.student_parent_notification(withdraw_request).deliver
    WithdrawalMailer.registration_notification(withdraw_request).deliver
  end


  private

  def get_withdraw_request_details_from_params
    withdraw_request_details = []
    params[:withdraw_request_detail][:student_id].each {|student_id|
      refund_registration_fee_in_cents = params["#{student_id}_refund_registration_fee_in_cents".to_sym]
      refund_tuition_in_cents = params["#{student_id}_refund_tuition_in_cents".to_sym]
      refund_book_charge_in_cents = params["#{student_id}_refund_book_charge_in_cents".to_sym]
      withdraw_request_detail = WithdrawRequestDetail.new
      withdraw_request_detail.student_id = student_id
      withdraw_request_detail.refund_registration_fee_in_cents = refund_registration_fee_in_cents
      withdraw_request_detail.refund_tuition_in_cents = refund_tuition_in_cents
      withdraw_request_detail.refund_book_charge_in_cents = refund_book_charge_in_cents
      withdraw_request_details << withdraw_request_detail
    }
    withdraw_request_details
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

  def init_withdraw_request
    registration_school_year = SchoolYear.find params[:id].to_i
    withdraw_request = WithdrawRequest.new
    withdraw_request.request_by = @user.person
    withdraw_request.request_by_name = @user.person.english_name
    withdraw_request.request_by_address =  @user.person.personal_address.nil? ? '' : @user.person.personal_address.street_address
    withdraw_request.school_year = registration_school_year
    withdraw_request.approved = false
    withdraw_request.cancelled = false
    withdraw_request.approved_by_id = 0
    withdraw_request.refund_pva_due_in_cents = 0
    withdraw_request.refund_ccca_due_in_cents = 0

    withdraw_student_count = 0
    find_possible_students.each do |student|
      selected_withdraw_student = params["#{student.id}_withdraw".to_sym]
      if (!selected_withdraw_student.nil? && selected_withdraw_student == "1")
        paid_student_fee_payment = student.find_paid_student_fee_payment_as_student_for(registration_school_year)
        unless paid_student_fee_payment.nil?
          withdraw_student_count += 1
          # withdraw_detail
          withdraw_request_detail = WithdrawRequestDetail.new
          withdraw_request_detail.student_id = student.id
          withdraw_request_detail.refund_registration_fee_in_cents = 0
          if registration_school_year.school_has_started?
            withdraw_request_detail.refund_book_charge_in_cents = 0
          else
            withdraw_request_detail.refund_book_charge_in_cents = paid_student_fee_payment.book_charge_in_cents
          end
          withdraw_request_detail.refund_tuition_in_cents = registration_school_year.tuition_in_cents_refund_due(paid_student_fee_payment)
          withdraw_request.withdraw_request_details << withdraw_request_detail
        end
      end
    end

    earliest_registration_payment = RegistrationPayment.find_earliest_paid_payment_for @user.person.find_families_as_parent[0], registration_school_year
    paid_student_fee_payments_in_family = find_paid_student_fee_payments_in_family_for registration_school_year
    paid_student_count = paid_student_fee_payments_in_family.size
    unless registration_school_year.school_has_started?
      if paid_student_count - withdraw_student_count >= 2
        # still have 2 or more students
        pva_fee_refund_in_cents = 0
        ccca_fee_refund_in_cents = 0
      elsif paid_student_count - withdraw_student_count == 1
        # still have 1 students
        pva_fee_refund_in_cents = earliest_registration_payment.pva_due_in_cents > registration_school_year.pva_membership_due_in_cents ?
                             registration_school_year.pva_membership_due_in_cents : earliest_registration_payment.pva_due_in_cents
        ccca_fee_refund_in_cents = 0
      elsif paid_student_count - withdraw_student_count <= 0
        # no registered students any more
        pva_fee_refund_in_cents = earliest_registration_payment.pva_due_in_cents * paid_student_count > registration_school_year.pva_membership_due_in_cents * 2 ?
                             registration_school_year.pva_membership_due_in_cents * 2 : earliest_registration_payment.pva_due_in_cents * paid_student_count
        ccca_fee_refund_in_cents = earliest_registration_payment.ccca_due_in_cents
      end

      withdraw_request.refund_pva_due_in_cents = pva_fee_refund_in_cents
      withdraw_request.refund_ccca_due_in_cents = ccca_fee_refund_in_cents
    end
    withdraw_request.caculate_refund_grand_total_in_cents
    withdraw_request
  end
end
