module Admin::SchoolYearsHelper
  def future_date_form_field(date_attribute_symbol, date_attribute_label, school_year_form)
    date_value = @school_year.send(date_attribute_symbol)
    if date_value.nil? or date_value >= PacificDate.today
      puts "#{date_attribute_symbol.to_s} nil? => #{date_value.nil?}"
      "<div><label for=\"#{date_attribute_symbol.to_s}\"><span style=\"color:red\">*&nbsp;</span>#{date_attribute_label}:</label>" +
          "#{school_year_form.text_field(date_attribute_symbol, {:class => 'jquery-datepicker'})}</div>"
    else
      "<div><label for=\"#{date_attribute_symbol.to_s}\">#{date_attribute_label}:</label>" +
          "#{school_year_form.text_field(date_attribute_symbol, {:disabled => true})}"
    end
  end
end
