# Monkey patch the Date class with new utilities
class PacificDate < Date
  def self.today
    Time.now.in_time_zone('Pacific Time (US & Canada)').to_date
  end
  
  def self.tomorrow
    self.today + 1
  end
end
