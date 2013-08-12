class Accounting::InPersonRegistrationPaymentsController < ApplicationController

  def index
    @registration_payments = RegistrationPayment.find_pending_in_person_payments_for SchoolYear.current_school_year
  end

  def payment_entry
    @registration_payment = RegistrationPayment.find_by_id params[:id].to_i
    if @registration_payment.paid?
      flash[:notice] = 'Registration already paid'
      redirect_to(:action => :index) and return
    end
    if request.post?
      @in_person_registration_transaction = InPersonRegistrationTransaction.new params[:in_person_registration_transaction]
      @in_person_registration_transaction.registration_payment = @registration_payment
      @in_person_registration_transaction.recorded_by = @user.person
      if @in_person_registration_transaction.valid?
        RegistrationPayment.transaction do
          @in_person_registration_transaction.save!
          @registration_payment.paid = true
          @registration_payment.save!
        end
        create_student_class_assignments
        email = ReceiptMailer.create_payment_confirmation @gateway_transaction, @registration_payment
        ReceiptMailer.deliver email
        flash[:notice] = 'In-person Registration Payment recorded successfully'
        redirect_to :action => :index
      end
    else
      @in_person_registration_transaction = InPersonRegistrationTransaction.new
    end
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
    redirect_to :action => 'index'
  end

  private

  def create_student_class_assignments
    school_year = @registration_payment.school_year
    @registration_payment.student_fee_payments.each do |student_fee_payment|
      student_fee_payment.student.create_student_class_assignment_based_on_registration_preference school_year
    end
  end
end
