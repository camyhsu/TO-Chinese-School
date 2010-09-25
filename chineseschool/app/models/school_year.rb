class SchoolYear < ActiveRecord::Base

  def self.current_school_year
    self.first :conditions => ["start_date < ? AND end_date > ?", Date.today, Date.today]
  end
  
  def self.find_current_and_future_school_years
    self.all :conditions => ["end_date > ?", Date.today], :order => 'end_date ASC'
  end
end
