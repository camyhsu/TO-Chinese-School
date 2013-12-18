class HomeController < ApplicationController

  skip_before_filter :check_authorization

  before_filter :find_user_in_session

  def index
    @home_templates = []
    @home_templates << 'principal' if principal_resources_enabled?
    #@home_templates << 'registration_officer' if registration_resources_enabled?
    @home_templates << 'accounting_officer' if accounting_resources_enabled?
    #@home_templates << 'activity_officer' if activity_resources_enabled?
    @home_templates << 'communication_officer' if communication_resources_enabled?
    @home_templates << 'instruction_officer' if instruction_resources_enabled?
    @home_templates << 'librarian' if librarian_resources_enabled?
    #@home_templates << 'ccca_staff' if ccca_staff_resources_enabled?
    @home_templates << 'instructor' if instructor_resources_enabled?
    @active_registration_school_years = SchoolYear.find_active_registration_school_years
    if student_parent_resources_enabled?
      @home_templates << 'student_parent'
      @possible_students = find_possible_students
    end
    @person = @user.person
  end

  def change_password
    if request.post?
      if @user.password_correct?(params[:current_password])
        if params[:new_password] == params[:new_password_confirmation]
          @user.password = params[:new_password]
          flash.now[:notice] = 'Password changed successfully' if @user.save
          # Error messages would be sent back to view if saving failed with validation errors
        else
          flash.now[:notice] = 'New Password does not match confirmation re-typed'
        end
      else
        flash.now[:notice] = 'Invalid current password'
      end
    end
  end


  private

  def principal_resources_enabled?
    return true if @user.has_role? Role::ROLE_NAME_SUPER_USER
    return true if @user.has_role? Role::ROLE_NAME_PRINCIPAL
    false
  end

  def registration_resources_enabled?
    return true if @user.has_role? Role::ROLE_NAME_SUPER_USER
    return true if @user.has_role? Role::ROLE_NAME_REGISTRATION_OFFICER
    false
  end

  def accounting_resources_enabled?
    return true if @user.has_role? Role::ROLE_NAME_SUPER_USER
    return true if @user.has_role? Role::ROLE_NAME_ACCOUNTING_OFFICER
    false
  end
  
  def activity_resources_enabled?
    return true if @user.has_role? Role::ROLE_NAME_SUPER_USER
    return true if @user.has_role? Role::ROLE_NAME_ACTIVITY_OFFICER
    false
  end

  def communication_resources_enabled?
    return true if @user.has_role? Role::ROLE_NAME_SUPER_USER
    return true if @user.has_role? Role::ROLE_NAME_COMMUNICATION_OFFICER
    false
  end
  
  def instruction_resources_enabled?
    return true if @user.has_role? Role::ROLE_NAME_SUPER_USER
    return true if @user.has_role? Role::ROLE_NAME_INSTRUCTION_OFFICER
    false
  end

  def librarian_resources_enabled?
    return true if @user.has_role? Role::ROLE_NAME_SUPER_USER
    return true if @user.has_role? Role::ROLE_NAME_LIBRARIAN
    false
  end
  
  def ccca_staff_resources_enabled?
    return true if @user.has_role? Role::ROLE_NAME_SUPER_USER
    return true if @user.has_role? Role::ROLE_NAME_CCCA_STAFF
    false
  end

  def instructor_resources_enabled?
    return true if @user.has_role? Role::ROLE_NAME_SUPER_USER
    return true if @user.has_role? Role::ROLE_NAME_INSTRUCTOR
    return true if @user.has_role? Role::ROLE_NAME_ROOM_PARENT
    false
  end

  def student_parent_resources_enabled?
    return true if @user.has_role? Role::ROLE_NAME_SUPER_USER
    return true if @user.has_role? Role::ROLE_NAME_STUDENT_PARENT
    false
  end
end
