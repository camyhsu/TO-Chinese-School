class Registration::StudentClassAssignmentsController < ApplicationController

  verify :only => [:select_school_class, :select_elective_class] , :method => :post,
      :add_flash => { :notice => 'Illegal GET' }, :redirect_to => { :action => 'index' }


  def grade
    @grade = Grade.find_by_id params[:grade][:id]
    render :layout => 'jquery_datatable'
  end

  def add_new_student
    
  end

  def select_school_class
    if request.post?
      @student_class_assignment = StudentClassAssignment.find_by_id params[:id].to_i
      selected_school_class = SchoolClass.find_by_id params[:selected_class_id]
      @student_class_assignment.school_class = selected_school_class
      @student_class_assignment.save!
      render :action => :one_student_class_assignment, :layout => 'ajax_layout'
    end
  end

  def select_elective_class
    if request.post?
      @student_class_assignment = StudentClassAssignment.find_by_id params[:id].to_i
      selected_elective_class = SchoolClass.find_by_id params[:selected_class_id]
      @student_class_assignment.elective_class = selected_elective_class
      @student_class_assignment.save!
      render :action => :one_student_class_assignment, :layout => 'ajax_layout'
    end
  end
end
