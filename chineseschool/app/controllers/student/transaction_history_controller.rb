class Student::TransactionHistoryController < ApplicationController
  
  def index
    @registration_payments = RegistrationPayment.find_paid_payments_paid_by @user.person
  end

  def show
    @registration_payment = RegistrationPayment.find_by_id params[:id].to_i
    unless @registration_payment.paid_by == @user.person
      flash[:notice] = 'Access to requested payment confirmation not authorized'
      redirect_to(:controller => '/home', :action => 'index') and return
    end
    @gateway_transaction = @registration_payment.find_first_approved_gateway_transaction
  end
  
  def show_for_staff
    @registration_payment = RegistrationPayment.find_by_id params[:id].to_i
    @gateway_transaction = @registration_payment.find_first_approved_gateway_transaction
  end
end
