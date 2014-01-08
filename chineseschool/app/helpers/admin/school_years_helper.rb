module Admin::SchoolYearsHelper
  def future_date_html_options(current_date_value)
    if current_date_value.nil? || current_date_value >= PacificDate.today
      {class: 'jquery-datepicker'}
    else
      {disabled: true}
    end
  end
end
