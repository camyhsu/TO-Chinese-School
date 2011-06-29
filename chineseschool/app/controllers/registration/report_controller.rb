class Registration::ReportController < ApplicationController

  def daily_registration_summary
    @registration_school_year = SchoolYear.find_by_id params[:id].to_i
    registration_summary_hash = {}
    RegistrationPayment.find_paid_payments_for(@registration_school_year).each do |paid_payment|
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

  private

  def extract_pacific_date_from(utc_time)
    utc_time.in_time_zone('Pacific Time (US & Canada)').to_date
  end

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
