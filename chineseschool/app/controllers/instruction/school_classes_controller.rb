class Instruction::SchoolClassesController < ApplicationController

  def show
    requested_school_class_id = params[:id].to_i
    unless instructor_assignment_verified? requested_school_class_id
      flash[:notice] = "Access to requested school class list not authorized"
      redirect_to :controller => '/home', :action => :index
      return
    end
    @school_class = SchoolClass.find_by_id requested_school_class_id
  end
  
  def display_room_parent_selection
    requested_school_class_id = params[:id].to_i
    unless instructor_assignment_verified? requested_school_class_id
      unless user_is_an_instructor? requested_school_class_id
        flash[:notice] = "Access to requested room parent selection not authorized"
        redirect_to :controller => '/home', :action => :index
        return
      end
    end
    @school_class = SchoolClass.find_by_id requested_school_class_id
    render :layout => 'ajax_layout'
  end

  def save_room_parent_selection
    requested_school_class_id = params[:id].to_i
    unless instructor_assignment_verified? requested_school_class_id
      unless user_is_an_instructor? requested_school_class_id
        flash[:notice] = "Access to requested room parent selection not authorized"
        redirect_to :controller => '/home', :action => :index
        return
      end
    end
    @school_class = SchoolClass.find_by_id requested_school_class_id


    InstructorAssignment.change_room_parent @school_class, params[:room_parent_id].to_i
    render :action => 'current_room_parent_display', :layout => 'ajax_layout'
  end

  def cancel_room_parent_selection
    requested_school_class_id = params[:id].to_i
    unless instructor_assignment_verified? requested_school_class_id
      unless user_is_an_instructor? requested_school_class_id
        flash[:notice] = "Access to requested room parent selection not authorized"
        redirect_to :controller => '/home', :action => :index
        return
      end
    end
    @school_class = SchoolClass.find_by_id requested_school_class_id
    render :action => 'current_room_parent_display', :layout => 'ajax_layout'
  end


  private

  def skip_instructor_assignment_verification
    @user.roles.any? do |role|
      role.name == Role::ROLE_NAME_SUPER_USER or
      role.name == Role::ROLE_NAME_PRINCIPAL or
      role.name == Role::ROLE_NAME_REGISTRATION_OFFICER or 
      role.name == Role::ROLE_NAME_INSTRUCTION_OFFICER or 
      role.name == Role::ROLE_NAME_ACTIVITY_OFFICER
    end
  end
  
  def user_is_an_instructor?(school_class_id)
    @user.person.instructor_assignments_for(SchoolYear.current_school_year).any? do |instructor_assignment|
      if instructor_assignment.school_class.id == school_class_id
        instructor_assignment.role_is_an_instructor?
      else
        false
      end
    end
  end
end
