# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  before_filter :ssl_required
  before_filter :check_authentication, :check_authorization
  

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password


  protected

  def ssl_required
    if RAILS_ENV == 'production'
      unless request.ssl?
        redirect_to("https://www.to-cs.org" + request.request_uri) and return false
      end
    end
  end

  def check_authentication
    unless session[:user_id]
      session[:original_uri] = request.request_uri
      redirect_to :controller => '/signin', :action => 'index' and return false
    end
  end

  def check_authorization
    user = User.find(session[:user_id])
    unless user.authorized?(controller_path, action_name)
      flash[:notice] = 'You are not authorized to view the page you requested'
      if request.env['HTTP_REFERER']
        redirect_to :back and false
      else
        redirect_to :controller => '/home', :action => 'index' and false
      end
    end
  end
end
