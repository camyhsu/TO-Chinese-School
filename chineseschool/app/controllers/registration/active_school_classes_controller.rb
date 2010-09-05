class Registration::ActiveSchoolClassesController < ApplicationController
  
  def index
    @active_school_classes = SchoolClass.all :conditions => 'active is true'
    render :layout => 'jquery_datatable'
  end
  
end
