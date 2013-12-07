class Instruction::ActiveSchoolClassesController < ApplicationController
  
  def index
    @active_school_classes = SchoolClass.find_all_active_school_classes
    render layout: 'jquery_datatable'
  end
  
end
