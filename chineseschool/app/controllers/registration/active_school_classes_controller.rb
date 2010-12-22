class Registration::ActiveSchoolClassesController < ApplicationController
  
  def index
    @active_school_classes = SchoolClass.all :conditions => 'active is true'
    render :layout => 'jquery_datatable'
  end

  def student_count
    @current_school_year = SchoolYear.current_school_year
    @active_grade_classes = SchoolClass.all(:conditions => 'active is true AND grade_id is not null', :order => 'grade_id ASC')
  end
end
