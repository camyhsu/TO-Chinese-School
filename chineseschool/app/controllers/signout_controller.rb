class SignoutController < ApplicationController

  skip_before_filter :check_authorization

  def index
    # TODO - remove session data about registration
    session[:user_id] = nil
    redirect_to(:controller => 'signin', :action => 'index')
  end
end
