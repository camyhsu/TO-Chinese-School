class HomeController < ApplicationController

  skip_before_filter :check_authorization

  before_filter :find_user_in_session

  def index
    @home_templates = []
    @home_templates << 'registration_officer' if registration_resources_enabled?
    @home_templates << 'instructor' if instructor_resources_enabled?
    @home_templates << 'student_parent' if student_parent_resources_enabled?
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

  def registration_resources_enabled?
    return true if @user.has_role? Role::ROLE_NAME_SUPER_USER
    return true if @user.has_role? Role::ROLE_NAME_REGISTRATION_OFFICER
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
