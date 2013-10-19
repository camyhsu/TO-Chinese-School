require 'spec_helper'

describe Admin::RightsController, 'displaying index' do
  before(:each) do
    stub_check_authentication_and_authorization_in @controller
    @fake_rights = []
  end

  it 'should find all rights' do
    Right.expects(:find).with(:all).once.returns(@fake_rights)
    get :index
  end

  it 'should assign rights found' do
    Right.expects(:find).with(:all).once.returns(@fake_rights)
    get :index
    assigns[:rights].should == @fake_rights
  end

  it 'should be success' do
    get :index
    response.should be_success
  end

  it 'should render index template' do
    get :index
    response.should render_template('admin/rights/index.html.erb')
  end

  it 'should respond to correct route' do
    { :get => '/chineseschool/admin/rights' }.should route_to( :controller => 'admin/rights', :action => 'index' )
  end
end
