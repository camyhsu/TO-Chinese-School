class Communication::FormsController < ApplicationController

  def picture_taking_form
    @current_school_year = SchoolYear.current_school_year
    retrieve_sorted_class_lists
    respond_to do |format|
      format.pdf {render layout: false}
    end
  end

  def student_list_for_yearbook
    retrieve_sorted_class_lists
    respond_to do |format|
      format.csv {
        headers['Content-Type'] = 'text/csv'
        headers['Content-Disposition'] = 'attachment; filename="student_list_for_yearbook.csv"'
        render layout: false
      }
    end
  end
end
