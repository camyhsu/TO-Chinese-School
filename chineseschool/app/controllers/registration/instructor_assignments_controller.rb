class Registration::InstructorAssignmentsController < ApplicationController
  
  verify :only => [:select_school_class, :select_role] , :method => :post,
      :add_flash => {:notice => 'Illegal GET'}, :redirect_to => {:controller => '/signout', :action => 'index'}

  def select_school_class
    @instructor_assignment = InstructorAssignment.find_by_id params[:id]
    @instructor_assignment.school_class = SchoolClass.find_by_id params[:selected_class_id]
    @instructor_assignment.save!
    render :action => :one_instructor_assignment, :layout => 'ajax_layout'
  end

  def select_start_date
    @instructor_assignment = InstructorAssignment.find_by_id params[:id]
    @instructor_assignment.start_date = parse_date params[:selected_date_string]
    @instructor_assignment.save!
    render :action => :one_instructor_assignment, :layout => 'ajax_layout'
  end

  def select_end_date
    @instructor_assignment = InstructorAssignment.find_by_id params[:id]
    @instructor_assignment.end_date = parse_date params[:selected_date_string]
    @instructor_assignment.save!
    render :action => :one_instructor_assignment, :layout => 'ajax_layout'
  end

  def select_role
    @instructor_assignment = InstructorAssignment.find_by_id params[:id]
    @instructor_assignment.role = params[:selected_role]
    @instructor_assignment.save!
    render :action => :one_instructor_assignment, :layout => 'ajax_layout'
  end
end
