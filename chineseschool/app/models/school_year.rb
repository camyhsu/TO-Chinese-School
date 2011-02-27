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
    
  end
end
