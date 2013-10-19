class Registration::ReportController < ApplicationController

  def daily_online_registration_summary
    @registration_school_year = SchoolYear.find_by_id params[:id].to_i
    registration_summary_hash = {}
    RegistrationPayment.find_paid_payments_for_school_year(@registration_school_year).each do |paid_payment|
      payment_date = extract_pacific_date_from(paid_payment.updated_at)
      summary_entry = find_or_create_summary_entry payment_date, registration_summary_hash
      add_payment_to summary_entry, paid_payment
    end
    @registration_summaries = registration_summary_hash.sort { |a, b| b[0] <=> a[0]}
    @student_count_total = 0
    @payment_total_in_cents = 0
    @registration_summaries.each do |summary|
      @student_count_total += summary[1][:student_count]
      @payment_total_in_cents += summary[1][:total_amount_in_cents]
    end
  end
  
  def registration_integrity
    @student_class_assignments_without_registration = StudentClassAssignment.find_by_sql [
        'select sca.id, sca.student_id from student_class_assignments sca ' + 
          'left outer join (select * from student_status_flags where school_year_id = ? and registered = true) ssf ' + 
          'on ssf.student_id = sca.student_id ' + 
          'where sca.school_year_id = ? and ssf.id is null', 
        SchoolYear.current_school_year.id, SchoolYear.current_school_year.id ]
    @student_status_flags_without_school_class_assignment = StudentClassAssignment.find_by_sql [
        'select ssf.id, ssf.student_id from student_status_flags ssf ' + 
          'left outer join (select * from student_class_assignments where school_year_id = ?) sca ' + 
          'on ssf.student_id = sca.student_id ' + 
          'where ssf.school_year_id = ? and registered = true and sca.id is null', 
        SchoolYear.current_school_year.id, SchoolYear.current_school_year.id ]
    @student_class_assignments_without_school_class = StudentClassAssignment.all :conditions => [ 'school_year_id = ? AND school_class_id is null', SchoolYear.current_school_year ]
  end

  private

  def find_or_create_summary_entry(payment_date, registration_summary_hash)
    summary_entry = registration_summary_hash[payment_date]
    if summary_entry.nil?
      summary_entry = {:student_count => 0, :total_amount_in_cents => 0}
      registration_summary_hash[payment_date] = summary_entry
    end
    summary_entry
  end

  def add_payment_to(summary_entry, paid_payment)
    summary_entry[:total_amount_in_cents] += paid_payment.grand_total_in_cents
    # This assumes that there are no mixed pay / refund payments
    if paid_payment.grand_total_in_cents < 0
      summary_entry[:student_count] -= paid_payment.student_fee_payments.size
    else
      summary_entry[:student_count] += paid_payment.student_fee_payments.size
    end
  end
end
