require 'spec_helper'

describe Admin::RolesController, 'displaying index' do
  before(:each) do
    stub_check_authentication_and_authorization_in @controller
    @fake_roles = []
  end

  it 'should find all roles' do
    Role.expects(:find).with(:all).once.returns(@fake_roles)
    get :index
  end

  it 'should assign roles found' do
    Role.expects(:find).with(:all).once.returns(@fake_roles)
    get :index
    assigns[:roles].should == @fake_roles
  end

  it 'should be success' do
    get :index
    response.should be_success
  end

  it 'should render index template' do
    get :index
    response.should render_template('admin/roles/index.html.erb')
  end

  it 'should respond to correct route' do
    { :get => '/chineseschool/admin/roles' }.should route_to( :controller => 'admin/roles', :action => 'index' )
  end
end


describe Admin::RolesController, 'displaying create role form' do
  before(:each) do
    stub_check_authentication_and_authorization_in @controller
    @new_role_created = Role.new
  end

  it 'should assign a new role' do
    Role.expects(:new).returns(@new_role_created)
    get :new
    assigns[:role].should == @new_role_created
  end

  it 'should be success' do
    get :new
    response.should be_success
  end

  it 'should render new template' do
    get :new
    response.should render_template('admin/roles/new.html.erb')
  end

  it 'should respond to correct route' do
    { :get => '/chineseschool/admin/roles/new' }.should route_to( :controller => 'admin/roles', :action => 'new' )
  end
end


describe Admin::RolesController, 'creating role successfully' do
  before(:each) do
    stub_check_authentication_and_authorization_in @controller
    new_role_name = random_string 8
    @role_parameters = { 'name' => new_role_name }
  end
  
  it 'should save a new role' do
    fake_new_role = Role.new
    Role.expects(:new).with(@role_parameters).once.returns(fake_new_role)
    fake_new_role.expects(:save).once
    post :create, :role => @role_parameters
  end

  it 'should redirect to index view' do
    post :create, :role => @role_parameters
    response.should redirect_to(:action => 'index')
  end

  it 'should respond to correct route' do
    { :post => '/chineseschool/admin/roles/create' }.should route_to( :controller => 'admin/roles', :action => 'create' )
  end
  
  it 'should redirect to index view if accessed using GET method' do
    get :create
    response.should redirect_to(:action => 'index')
    flash[:notice].should == 'Illegal GET'
  end
end


describe Admin::RolesController, 'failing to create role, tested with views' do
  integrate_views
  fixtures :roles
  
  before(:each) do
    stub_check_authentication_and_authorization_in @controller
  end

  it 'should display error message in the form if role name is empty' do
    post :create, :role => {}
    response.should render_template(:new)
    response.should include_text("Name can't be blank")
  end

  it 'should display error message in the form if role name is already taken' do
    post :create, :role => { :name => 'Super User'}
    response.should render_template(:new)
    response.should include_text('Name has already been taken')
  end
end
