class Activity::FormsController < ApplicationController
  
  def fire_drill_form
    @current_school_year = SchoolYear.current_school_year
    retrieve_sorted_class_lists
    respond_to do |format|
      format.pdf {render layout: false}
    end
  end
  
  def students_by_class
    retrieve_sorted_class_lists
    headers["Content-Type"] = 'text/csv'
    headers["Content-Disposition"] = 'attachment; filename="students_by_class.csv"'
    render :layout => false
  end
  
  def grade_class_information
    @active_classes = SchoolClass.find_all_active_grade_classes
    @active_classes.sort! { |x, y| x.grade_id <=> y.grade_id }
    headers["Content-Type"] = 'text/csv'
    headers["Content-Disposition"] = 'attachment; filename="grade_class_information.csv"'
    render :action => 'class_information', :layout => false
  end
  
  def elective_class_information
    @active_classes = SchoolClass.find_all_active_elective_classes
    @active_classes.sort! { |x, y| x.english_name <=> y.english_name }
    headers["Content-Type"] = 'text/csv'
    headers["Content-Disposition"] = 'attachment; filename="elective_class_information.csv"'
    render :action => 'class_information', :layout => false
  end
end
