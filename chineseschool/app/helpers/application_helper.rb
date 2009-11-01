# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def convert_to_yes_no(flag)
    return 'Yes' if flag
    'No'
  end
end
