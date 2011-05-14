class Registration::ActiveSchoolClassesController < ApplicationController
  
  def index
    @active_school_classes = SchoolClass.find_all_active_school_classes
    render :layout => 'jquery_datatable'
  end

  def student_count
    @current_school_year = SchoolYear.current_school_year
    @active_grade_classes = SchoolClass.find_all_active_school_classes.reject { |school_class| school_class.elective? }
    @active_grade_classes.sort! { |x, y| x.grade_id <=> y.grade_id }
  end
end
