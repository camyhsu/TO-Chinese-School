class Registration::ActiveSchoolClassesController < ApplicationController
  
  def index
    @active_school_classes = SchoolClass.find_all_active_school_classes
    render :layout => 'jquery_datatable'
  end

  def grade_class_student_count
    @current_school_year = SchoolYear.current_school_year
    @active_grade_classes = SchoolClass.find_all_active_grade_classes
    @active_grade_classes.sort! { |x, y| x.grade_id <=> y.grade_id }
  end
  
  def elective_class_student_count
    @current_school_year = SchoolYear.current_school_year
    @active_elective_classes = SchoolClass.find_all_active_elective_classes
    @active_elective_classes.sort! { |x, y| x.english_name <=> y.english_name }
  end
end
