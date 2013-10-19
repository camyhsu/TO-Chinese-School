require 'spec_helper'

describe Admin::SchoolClassesController, 'displaying index' do
  before(:each) do
    stub_check_authentication_and_authorization_in @controller
    @fake_school_classes = []
  end

  it 'should find all school classes' do
    SchoolClass.expects(:find).with(:all).once.returns(@fake_school_classes)
    get :index
  end

  it 'should assign school classes found' do
    SchoolClass.expects(:find).with(:all).once.returns(@fake_school_classes)
    get :index
    assigns[:school_classes].should == @fake_school_classes
  end

  it 'should be success' do
    get :index
    response.should be_success
  end

  it 'should render index template' do
    get :index
    response.should render_template('admin/school_classes/index.html.erb')
  end

  it 'should respond to correct route' do
    { :get => '/chineseschool/admin/school_classes' }.should route_to( :controller => 'admin/school_classes', :action => 'index' )
  end
end
