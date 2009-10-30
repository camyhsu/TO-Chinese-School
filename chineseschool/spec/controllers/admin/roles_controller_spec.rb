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


describe Admin::RolesController, 'displaying create form' do
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
