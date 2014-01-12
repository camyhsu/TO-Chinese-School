class Accounting::InPersonRegistrationPaymentsController < ApplicationController

  def index
    @registration_payments = RegistrationPayment.find_pending_in_person_payments_for SchoolYear.current_school_year
    # Exclude payments related to student who has registered already
    @registration_payments.reject! { |registration_payment| registration_payment.at_least_one_student_already_registered? }
  end

  def payment_entry
    @registration_payment = RegistrationPayment.find params[:id].to_i
    if @registration_payment.paid?
      flash[:notice] = 'Registration already paid'
      redirect_to(action: :index) and return
    end
    if request.post? || request.put?
      @in_person_registration_transaction = InPersonRegistrationTransaction.new params[:in_person_registration_transaction]
      @in_person_registration_transaction.registration_payment = @registration_payment
      @in_person_registration_transaction.recorded_by = @user.person
      if @in_person_registration_transaction.valid?
        RegistrationPayment.transaction do
          @in_person_registration_transaction.save!
          @registration_payment.paid = true
          @registration_payment.save!
        end
        @registration_payment.create_student_class_assignments
        @registration_payment.send_email_notification
        flash[:notice] = 'In-person Registration Payment recorded successfully'
        redirect_to action: :index
      end
    else
      @in_person_registration_transaction = InPersonRegistrationTransaction.new
    end
  end

  def remove_pending_registration_payment
    registration_payment = RegistrationPayment.find params[:id].to_i
    if registration_payment.nil?
      logger.warn "Could not find registration payment with id => #{params[:id]}"
    else
      if registration_payment.paid? or (not registration_payment.gateway_transactions.empty?)
        logger.warn "Attempting to remove a processed registration #{registration_payment.id} by user #{@user.id}"
      else
        registration_payment.destroy
      end
    end
    redirect_to action: :index
  end
end
