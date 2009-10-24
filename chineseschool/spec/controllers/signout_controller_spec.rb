require 'spec_helper'

describe SignoutController do
  before(:each) do
    session[:user_id] = rand 1000
  end

  it 'should clear the user id from session' do
    get :index
    session[:user_id].should be_nil
  end
  
  it 'should redirect to signin page' do
    get :index
    response.should redirect_to(:controller => 'signin', :action => 'index')
  end
  
  it 'should respond to correct route' do
    { :get => '/chineseschool/signout' }.should route_to( :controller => 'signout', :action => 'index' )
  end
end
