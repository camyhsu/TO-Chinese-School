require 'spec_helper'

describe Registration::PeopleController, 'displaying index' do
  before(:each) do
    stub_check_authentication_and_authorization_in @controller
    @fake_people = []
  end

  it 'should find all people' do
    Person.expects(:find).with(:all).once.returns(@fake_people)
    get :index
  end

  it 'should assign people found' do
    Person.expects(:find).with(:all).once.returns(@fake_people)
    get :index
    assigns[:people].should == @fake_people
  end

  it 'should be success' do
    get :index
    response.should be_success
  end

  it 'should render index template' do
    get :index
    response.should render_template('registration/people/index.html.erb')
  end

  it 'should respond to correct route' do
    { :get => '/chineseschool/registration/people' }.should route_to( :controller => 'registration/people', :action => 'index' )
  end
end
