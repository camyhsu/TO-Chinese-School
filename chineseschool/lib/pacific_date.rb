class PacificDate
  
  def self.start_time_utc_for(date)
    date.to_time.utc
  end
  
  def self.today
    Time.now.in_time_zone('Pacific Time (US & Canada)').to_date
  end
  
  def self.tomorrow
    self.today + 1
  end
end
