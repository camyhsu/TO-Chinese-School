class SigninController < ApplicationController

  def index
    if request.post?
      user_found = User.authenticate(params[:username], params[:password])
      if user_found
        session[:user_id] = user_found.id
        redirect_to(:controller => 'home', :action => 'index')
      else
        flash.now[:notice] = 'Invalid username / password combination'
      end
    end
  end
end
