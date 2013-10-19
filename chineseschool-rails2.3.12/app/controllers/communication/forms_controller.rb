class Communication::FormsController < ApplicationController

  def picture_taking_form
    @current_school_year = SchoolYear.current_school_year
    retrieve_sorted_class_lists
    prawnto :filename => 'picture_taking_form.pdf'
    render :layout => false
  end

  def student_list_for_yearbook
    retrieve_sorted_class_lists
    headers["Content-Type"] = 'text/csv'
    headers["Content-Disposition"] = 'attachment; filename="student_list_for_yearbook.csv"'
    render :layout => false
  end
end
