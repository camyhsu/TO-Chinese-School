require 'spec_helper'

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
    @fake_user = User.new
    @fake_user.id = rand(10000)
  end
  
  it 'should authenticate username and password' do
    User.expects(:authenticate).with(@fake_username, @fake_password).once
    post :index, :username => @fake_username, :password => @fake_password
    #response.should be_success
  end
  
  it 'should assign user id to session if authentication is successful' do
    User.expects(:authenticate).with(@fake_username, @fake_password).once.returns(@fake_user)
    post :index, :username => @fake_username, :password => @fake_password
    session[:user_id].should == @fake_user.id
  end
  
  it 'should redirect to home page if authentication is successful' do
    User.expects(:authenticate).with(@fake_username, @fake_password).once.returns(@fake_user)
    post :index, :username => @fake_username, :password => @fake_password
    response.should redirect_to(:controller => 'home', :action => 'index')
  end
  
  it 'should respond to correct route' do
    { :post => '/chineseschool/signin' }.should route_to( :controller => 'signin', :action => 'index' )
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

