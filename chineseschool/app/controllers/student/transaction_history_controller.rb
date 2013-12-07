class Student::TransactionHistoryController < ApplicationController
  
  def index
    @registration_payments = RegistrationPayment.find_paid_payments_paid_by @user.person
    @manual_transactions = ManualTransaction.all conditions: ['transaction_by_id = ?', @user.person.id], order: 'transaction_date DESC'
  end

  def show_registration_payment
    @registration_payment = RegistrationPayment.find params[:id].to_i
    unless @registration_payment.paid_by == @user.person
      flash[:notice] = 'Access to requested payment confirmation not authorized'
      redirect_to controller: '/home'
      return
    end
    @gateway_transaction = @registration_payment.find_first_approved_gateway_transaction
  end
  
  def show_registration_payment_for_staff
    @registration_payment = RegistrationPayment.find params[:id].to_i
    @gateway_transaction = @registration_payment.find_first_approved_gateway_transaction
  end
  
  def show_manual_transaction
    @manual_transaction = ManualTransaction.find params[:id].to_i
    unless @manual_transaction.transaction_by == @user.person
      flash[:notice] = 'Access to requested payment information not authorized'
      redirect_to controller: '/home'
    end
  end
end
