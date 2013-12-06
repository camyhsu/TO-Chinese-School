module ApplicationHelper

  def convert_to_yes_no(flag)
    return 'Yes' if flag
    'No'
  end
end
