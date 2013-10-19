require 'spec_helper'

describe ApplicationController, 'enforcing ssl in production mode' do
  before(:each) do
    @saved_rails_env = RAILS_ENV
    RAILS_ENV = 'production'
    @controller = TestController.new
  end

  after(:each) do
    RAILS_ENV = @saved_rails_env
  end
  
  it 'should not redirect when access through ssl' do
    stub_check_authentication_and_authorization_in @controller
    request.expects(:ssl?).once.returns(true)
    get :index
    response.should_not be_redirect
  end
  
  it 'should redirect to url with prescribed prefix when access through plain http' do
    request.expects(:ssl?).once.returns(false)
    get :index
    response.should be_redirect
    response.should redirect_to('https://www.to-cs.org/chineseschool/test')
  end

  it 'should stop the filter chain if redirect' do
    @controller.request = request
    @controller.response = response
    request.expects(:ssl?).once.returns(false)
    @controller.ssl_required.should be_false
  end
end


describe ApplicationController, 'not enforcing ssl when not in production mode' do
  before(:each) do
    @controller = TestController.new
  end

  it 'should not redirect' do
    stub_check_authentication_and_authorization_in @controller
    get :index
    response.should_not be_redirect
  end
end


describe ApplicationController, 'checking authentication' do
  before(:each) do
    @controller = TestController.new
  end

  it 'should not redirect if user exists in session' do
    stub_check_authorization_in @controller
    session[:user_id] = rand 1000
    get :index
    response.should_not be_redirect
  end

  it 'should keep the request uri in session if no user exists in session' do
    get :index
    session[:original_uri].should == '/chineseschool/test'
  end

  it 'should redirect to signin if no user exists in session' do
    get :index
    response.should be_redirect
    response.should redirect_to(:controller => '/signin', :action => 'index')
  end

  it 'should stop the filter chain if redirect' do
    @controller.request = request
    @controller.session = session
    @controller.expects(:redirect_to).once.returns(true)
    @controller.check_authentication.should be_false
  end
end


describe ApplicationController, 'checking authorization' do
  before(:each) do
    @controller = TestController.new
    @fake_user = User.new
    expect_all_test_cases_to_find_the_user_whose_id_is_in_session
  end
  
  def expect_all_test_cases_to_find_the_user_whose_id_is_in_session
    user_id_in_session = rand 1000
    session[:user_id] = user_id_in_session
    User.expects(:find).with(user_id_in_session).once.returns(@fake_user)
  end

  it 'should find the user whose id is in session' do
    get :index
  end

  it 'should not redirect if authorization is successful' do
    @fake_user.expects(:authorized?).with('test', 'index').once.returns(true)
    get :index
    response.should_not be_redirect
  end

  it 'should set flash notice if authorization fails' do
    get :index
    flash[:notice].should == 'You are not authorized to view the page you requested'
  end
  
  it 'should redirect to the previous page if authorization fails and previous page exists' do
    previous_page_uri = random_uri
    request.env['HTTP_REFERER'] = previous_page_uri
    get :index
    response.should redirect_to(previous_page_uri)
  end

  it 'should redirect to home page if authorization fails but no previous page exists' do
    get :index
    response.should redirect_to(:controller => '/home', :action => 'index')
  end

  it 'should stop the filter chain if redirect to previous page' do
    @controller.request = request
    @controller.session = session
    request.env['HTTP_REFERER'] = random_uri
    @controller.expects(:redirect_to).once.returns(true)
    @controller.check_authorization.should be_false
  end

  it 'should stop the filter chain if redirect to home page' do
    @controller.request = request
    @controller.session = session
    @controller.expects(:redirect_to).once.returns(true)
    @controller.check_authorization.should be_false
  end
end


describe ApplicationController, 'not exposing protected method' do
  it 'should mark ssl_required as a protected method' do
    controller.protected_methods.should include('ssl_required')
  end

  it 'should mark check_authentication as a protected method' do
    controller.protected_methods.should include('check_authentication')
  end

  it 'should mark check_authorization as a protected method' do
    controller.protected_methods.should include('check_authorization')
  end
end


class TestController < ApplicationController
  def index
    render :nothing => true
  end

  public :ssl_required, :check_authentication, :check_authorization
end
