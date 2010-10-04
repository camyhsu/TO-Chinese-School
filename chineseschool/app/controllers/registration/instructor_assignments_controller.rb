class Registration::InstructorAssignmentsController < ApplicationController
  
  verify :method => :post,
      :add_flash => {:notice => 'Illegal GET'}, :redirect_to => {:controller => '/signout', :action => 'index'}

  def destroy
    instructor_assignment = InstructorAssignment.find_by_id params[:id].to_i
    instructor_assignment.destroy
    instructor_user = instructor_assignment.instructor.user
    instructor_user.adjust_instructor_roles if instructor_user
    render :text => 'destroy_successful'
  end

  def select_school_class
    @instructor_assignment = InstructorAssignment.find_by_id params[:id]
    old_school_class = @instructor_assignment.school_class
    @instructor_assignment.school_class = SchoolClass.find_by_id params[:selected_class_id]
    if not @instructor_assignment.save
      @instructor_assignment.school_class = old_school_class  # change it back to the old value for display
    end
    render :action => :one_instructor_assignment, :layout => 'ajax_layout'
  end

  def select_start_date
    @instructor_assignment = InstructorAssignment.find_by_id params[:id]
    old_start_date = @instructor_assignment.start_date
    @instructor_assignment.start_date = parse_date params[:selected_date_string]
    if not @instructor_assignment.save
      @instructor_assignment.start_date = old_start_date  # change it back to the old value for display
    end
    render :action => :one_instructor_assignment, :layout => 'ajax_layout'
  end

  def select_end_date
    @instructor_assignment = InstructorAssignment.find_by_id params[:id]
    old_end_date = @instructor_assignment.end_date
    @instructor_assignment.end_date = parse_date params[:selected_date_string]
    if not @instructor_assignment.save
      @instructor_assignment.end_date = old_end_date  # change it back to the old value for display
    end
    render :action => :one_instructor_assignment, :layout => 'ajax_layout'
  end

  def select_role
    @instructor_assignment = InstructorAssignment.find_by_id params[:id]
    old_role = @instructor_assignment.role
    @instructor_assignment.role = params[:selected_role]
    if @instructor_assignment.save
      instructor_user = @instructor_assignment.instructor.user
      instructor_user.adjust_instructor_roles if instructor_user
    else
      @instructor_assignment.role = old_role  # change it back to the old value for display
    end
    render :action => :one_instructor_assignment, :layout => 'ajax_layout'
  end
end
