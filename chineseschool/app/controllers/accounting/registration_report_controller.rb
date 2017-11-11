class Accounting::RegistrationReportController < ApplicationController

  TUITION_QUERY =<<EOSQL
SELECT SUM(student_fee_payments.registration_fee_in_cents) as registration_fee_total, 
SUM(student_fee_payments.tuition_in_cents) as tuition_total, 
SUM(student_fee_payments.book_charge_in_cents) as book_charge_total 
FROM student_fee_payments 
JOIN registration_payments ON student_fee_payments.registration_payment_id = registration_payments.id 
WHERE registration_payments.paid = TRUE AND registration_payments.school_year_id =
EOSQL

  def registration_payments_by_date
    @registration_date = Date.parse params[:date]
    @paid_registration_payments = RegistrationPayment.find_paid_payments_for_date @registration_date
  end

  def charges_collected_report
    @registration_school_year = SchoolYear.find params[:id].to_i
    tuition_query_result = RegistrationPayment.connection.select_all(TUITION_QUERY + @registration_school_year.id.to_s)
    @charges_collected = {}
    @charges_collected[:registration_fee_in_cents] = tuition_query_result[0]['registration_fee_total'].to_i
    @charges_collected[:tuition_in_cents] = tuition_query_result[0]['tuition_total'].to_i
    @charges_collected[:book_charge_in_cents] = tuition_query_result[0]['book_charge_total'].to_i
    @charges_collected[:pva_due_in_cents] = RegistrationPayment.where('school_year_id = ? AND paid = TRUE', @registration_school_year.id).sum('pva_due_in_cents')
    @charges_collected[:ccca_due_in_cents] = RegistrationPayment.where('school_year_id = ? AND paid = TRUE', @registration_school_year.id).sum('ccca_due_in_cents')
  end
end
