class SigninController < ApplicationController

  skip_before_filter :check_authentication
  
  def index
    if request.post?
      user_found = User.authenticate(params[:username], params[:password])
      if user_found
        session[:user_id] = user_found.id
        original_uri = session[:original_uri]
        session[:original_uri] = nil
        redirect_to(original_uri || { :controller => 'home', :action => 'index' })
      else
        flash.now[:notice] = 'Invalid username / password combination'
      end
    end
  end
end
