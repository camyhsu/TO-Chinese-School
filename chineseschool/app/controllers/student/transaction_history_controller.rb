class Student::TransactionHistoryController < ApplicationController
  
  def index
    @registration_payments = RegistrationPayment.find_paid_transactions @user.person.id
  end

  def show
    @registration_payment = RegistrationPayment.find_by_id params[:id].to_i
    @gateway_transaction = @registration_payment.find_first_approved_gateway_transaction
  end
end
