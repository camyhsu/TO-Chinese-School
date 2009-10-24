class SignoutController < ApplicationController

  def index
    session[:user_id] = nil
    redirect_to(:controller => 'signin', :action => 'index')
  end

end
