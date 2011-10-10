class PacificDate
  
  def self.start_time_utc_for(date)
    server_local_start_time = date.to_time
    sample_pacific_time = server_local_start_time.in_time_zone('Pacific Time (US & Canada)')
    Time.at(server_local_start_time + server_local_start_time.utc_offset - sample_pacific_time.utc_offset).utc
  end
  
  def self.for_utc(time)
    time.in_time_zone('Pacific Time (US & Canada)').to_date
  end
  
  def self.today
    Time.now.in_time_zone('Pacific Time (US & Canada)').to_date
  end
  
  def self.tomorrow
    self.today + 1
  end
end
