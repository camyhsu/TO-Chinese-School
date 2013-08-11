class Accounting::InPersonRegistrationPaymentsController < ApplicationController

  def index
    @registration_payments = RegistrationPayment.find_pending_in_person_payments_for SchoolYear.current_school_year
  end
end
