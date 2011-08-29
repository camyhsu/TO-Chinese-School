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


  private

  def instructor_assignment_verified?(requested_school_class_id)
    return true if skip_instructor_assignment_verification
    @user.person.instructor_assignments_for(SchoolYear.current_school_year).any? do |instructor_assignment|
      instructor_assignment.school_class.id == requested_school_class_id
    end
  end

  def skip_instructor_assignment_verification
    @user.roles.any? do |role|
      role.name == Role::ROLE_NAME_SUPER_USER or 
      role.name == Role::ROLE_NAME_REGISTRATION_OFFICER or 
      role.name == Role::ROLE_NAME_INSTRUCTION_OFFICER
    end
  end
end
