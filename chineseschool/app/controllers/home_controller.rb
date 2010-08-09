class HomeController < ApplicationController

  skip_before_filter :check_authorization

  before_filter :find_user_in_session

  def index
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
end
