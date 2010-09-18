class SchoolYear < ActiveRecord::Base

  def self.find_current_and_future_school_years
    self.all :conditions => ["end_date > ?", Date.today], :order => 'end_date ASC'
  end
end
