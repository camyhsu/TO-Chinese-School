class PacificTimeDisplay

  def self.display_utc_time_in_pacific(utc_time)
    return nil if utc_time.nil?
    utc_time.in_time_zone('Pacific Time (US & Canada)').to_formatted_s(:long)
  end

  def self.display_now_in_pacific
    Time.now.in_time_zone('Pacific Time (US & Canada)').to_formatted_s(:long)
  end
end
