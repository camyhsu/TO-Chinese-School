class Accounting::RegistrationReportController < ApplicationController
  
  def registration_payments_by_date
    @registration_date = Date.parse params[:date]
    
  end

end
