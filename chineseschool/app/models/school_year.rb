class SchoolYear < ActiveRecord::Base

  validates_presence_of :name, :start_date, :end_date, :age_cutoff_month,
      :registration_start_date, :registration_75_percent_date,
      :registration_50_percent_date, :registration_end_date,
      :refund_75_percent_date, :refund_50_percent_date,
      :refund_25_percent_date, :refund_end_date

  validate :date_order

  def self.current_school_year
    self.first :conditions => ["start_date < ? AND end_date > ?", Date.today, Date.today]
  end
  
  def self.find_current_and_future_school_years
    self.all :conditions => ["end_date > ?", Date.today], :order => 'end_date ASC'
  end

  private

  def date_order
    validate_start_end_date_order
    #validate_registration_date_order
    #validate_refund_date_order
  end

  def validate_start_end_date_order
    validate_date_in_order :start_date, :end_date
  end

  def validate_date_in_order(earlier_date_symbol, later_date_symbol)
    earlier_date = self.send earlier_date_symbol
    later_date = self.send later_date_symbol
    return if earlier_date.nil? or later_date.nil?
    if earlier_date > later_date
      errors.add(earlier_date_symbol, " can not be later than #{later_date_symbol.to_s.humanize}")
    end
  end
end
