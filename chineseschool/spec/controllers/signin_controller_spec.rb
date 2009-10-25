require 'spec_helper'

describe SigninController do
  it 'should not check authentication' do
    controller.expects(:check_authentication).never
    get :index
  end

  it 'should not check authorization' do
    controller.expects(:check_authorization).never
    get :index
  end
end


describe SigninController, 'handling get request for signin' do
  it 'should be success' do
    get :index
    response.should be_success
  end

  it 'should render index template' do
    get :index
    response.should render_template('signin/index.html.erb')
  end

  it 'should not authenticate' do
    User.expects(:authenticate).never
    get :index
  end
  
  it 'should respond to correct route' do
    { :get => '/chineseschool/signin' }.should route_to( :controller => 'signin', :action => 'index' )
  end
end


describe SigninController, 'handling post request for singin' do
  before(:each) do
    @fake_username = random_string 8
    @fake_password = random_string 10
  end
  
  it 'should authenticate username and password' do
    User.expects(:authenticate).with(@fake_username, @fake_password).once
    post :index, :username => @fake_username, :password => @fake_password
    #response.should be_success
  end
  
  it 'should respond to correct route' do
    { :post => '/chineseschool/signin' }.should route_to( :controller => 'signin', :action => 'index' )
  end
end


describe SigninController, 'upon successful authentication for singin' do
  before(:each) do
    @fake_username = random_string 8
    @fake_password = random_string 10
    @fake_uri = random_uri
    @fake_user = User.new
    @fake_user.id = rand(10000)
    User.expects(:authenticate).with(@fake_username, @fake_password).once.returns(@fake_user)
  end
  
  it 'should assign user id to session' do
    post :index, :username => @fake_username, :password => @fake_password
    session[:user_id].should == @fake_user.id
  end
  
  it 'should redirect to home page if session does not contain original uri' do
    post :index, :username => @fake_username, :password => @fake_password
    response.should redirect_to(:controller => 'home', :action => 'index')
  end
  
  it 'should redirect to original uri if it exists in session' do
    session[:original_uri] = @fake_uri
    post :index, :username => @fake_username, :password => @fake_password
    response.should redirect_to(@fake_uri)
  end
  
  it 'should clear original uri out of session if it exists in session' do
    session[:original_uri] = @fake_uri
    post :index, :username => @fake_username, :password => @fake_password
    session[:original_uri].should be_nil
  end
end


describe SigninController, 'handling post request for singin, tested with views,' do
  integrate_views

  before(:each) do
    @fake_username = random_string 8
    @fake_password = random_string 10
  end
  
  it 'should display flash notice in login form if authentication fails' do
    User.expects(:authenticate).with(@fake_username, @fake_password).once.returns(nil)
    post :index, :username => @fake_username, :password => @fake_password
    response.should render_template(:index)
    response.should have_tag('p#flash-notice', 'Invalid username / password combination')
  end
end

