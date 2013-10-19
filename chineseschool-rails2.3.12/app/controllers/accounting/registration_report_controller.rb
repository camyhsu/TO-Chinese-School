class Accounting::RegistrationReportController < ApplicationController
  
  def registration_payments_by_date
    @registration_date = Date.parse params[:date]
    @paid_registration_payments = RegistrationPayment.find_paid_payments_for_date @registration_date
  end

end
