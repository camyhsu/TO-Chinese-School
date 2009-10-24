require 'spec_helper'

describe ApplicationController, 'enforcing ssl in production mode' do
  before(:each) do
    @saved_rails_env = RAILS_ENV
    RAILS_ENV = 'production'
    @controller = TestController.new
    stub_check_authentication_in @controller
  end

  after(:each) do
    RAILS_ENV = @saved_rails_env
  end
  
  it 'should redirect to url with prescribed prefix when access through plain http' do
    get :index
    response.should be_redirect
    response.should redirect_to('https://www.to-cs.org/chineseschool/test')
  end
  
  it 'should not redirect when access through ssl' do
    request.expects(:ssl?).once.returns(true)
    get :index
    response.should_not be_redirect
  end
end


describe ApplicationController, 'not enforcing ssl when not in production mode' do
  before(:each) do
    @controller = TestController.new
    stub_check_authentication_in @controller
  end

  it 'should not redirect' do
    get :index
    response.should_not be_redirect
  end
end


describe ApplicationController, 'checking authentication' do
  before(:each) do
    @controller = TestController.new
  end

  it 'should not redirect if user exists in session' do
    session[:user_id] = rand 1000
    get :index
    response.should_not be_redirect
  end

  it 'should redirect to signin if no user exists in session' do
    get :index
    response.should be_redirect
    response.should redirect_to(:controller => '/signin', :action => 'index')
  end


end


describe ApplicationController, 'not exposing protected method' do
  it 'should mark ssl_required as a protected method' do
    controller.protected_methods.should include('ssl_required')
  end

  it 'should mark check_authentication as a protected method' do
    controller.protected_methods.should include('check_authentication')
  end
end


class TestController < ApplicationController
  def index
    render :nothing => true
  end
end
