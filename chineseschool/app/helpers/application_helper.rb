# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def convert_to_yes_no(flag)
    return 'Yes' if flag
    'No'
  end

  def display_utc_time_in_pacific(utc_time)
    utc_time.in_time_zone('Pacific Time (US & Canada)').to_formatted_s(:long)
  end
end
