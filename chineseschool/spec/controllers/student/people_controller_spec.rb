require 'spec_helper'

describe Student::PeopleController, 'checking authorization' do
  before(:each) do
    stub_check_authentication_in @controller
    set_up_fake_person
    set_up_user_finding_in_authorization
    set_up_person_finding_by_id
  end
  
  it 'should not redirect if the user is allowed to edit personal data' do
    get :edit, {:id => @fake_person_id}
    response.should_not be_redirect
  end

  it 'should set flash notice if editing personal data is not allowed' do
    get :edit, {:id => rand(100000)}
    flash[:notice].should == 'Access to requested personal data not authorized'
  end
  
  it 'should redirect to home page if editing personal data is not allowed' do
    get :edit, {:id => rand(100000)}
    response.should redirect_to(:controller => '/home', :action => :index)
  end

  it 'should not redirect if the user is allowed to create personal address' do
    get :new_address, {:id => @fake_person_id}
    response.should_not be_redirect
  end

  it 'should set flash notice if creating personal address is not allowed' do
    get :new_address, {:id => rand(100000)}
    flash[:notice].should == 'Access to requested personal data not authorized'
  end

  it 'should redirect to home page if creating personal address is not allowed' do
    get :new_address, {:id => rand(100000)}
    response.should redirect_to(:controller => '/home', :action => :index)
  end

  it 'should not redirect if the user is allowed to edit personal address' do
    get :edit_address, {:id => @fake_person_id}
    response.should_not be_redirect
  end

  it 'should set flash notice if editing personal address is not allowed' do
    get :edit_address, {:id => rand(100000)}
    flash[:notice].should == 'Access to requested personal data not authorized'
  end

  it 'should redirect to home page if editing personal address is not allowed' do
    get :edit_address, {:id => rand(100000)}
    response.should redirect_to(:controller => '/home', :action => :index)
  end
end

describe Student::PeopleController, 'editing personal data' do
  # This controller uses template from other controllers, so we force rendering
  # of views in these test to make sure there are no path issues for partials
  integrate_views

  before(:each) do
    stub_check_authentication_in @controller
    set_up_fake_person
    set_up_user_finding_in_authorization
    set_up_person_finding_by_id
    @controller.stubs(:action_authorized?).returns(true)
  end

  it 'should re-use view template for /registration/people/edit' do
    get :edit, {:id => @fake_person_id}
    response.should render_template('registration/people/edit.html.erb')
  end
end

describe Student::PeopleController, 'creating personal address' do
  # This controller uses template from other controllers, so we force rendering
  # of views in these test to make sure there are no path issues for partials
  integrate_views

  before(:each) do
    stub_check_authentication_in @controller
    set_up_fake_person
    set_up_user_finding_in_authorization
    set_up_person_finding_by_id
    @controller.stubs(:action_authorized?).returns(true)
  end

  it 'should re-use view template for /registration/people/new_address' do
    get :new_address, {:id => @fake_person_id}
    response.should render_template('registration/people/new_address.html.erb')
  end
end

describe Student::PeopleController, 'editing personal address' do
  # This controller uses template from other controllers, so we force rendering
  # of views in these test to make sure there are no path issues for partials
  integrate_views

  before(:each) do
    stub_check_authentication_in @controller
    set_up_fake_person
    set_up_user_finding_in_authorization
    set_up_person_finding_by_id
    @controller.stubs(:action_authorized?).returns(true)
  end

  it 'should re-use view template for /registration/people/new_address' do
    get :edit_address, {:id => @fake_person_id}
    response.should render_template('registration/people/edit_address.html.erb')
  end
end

def set_up_fake_person
  @fake_person = Person.new
  @fake_person_id = rand 100000
  @fake_person.id = @fake_person_id
  fake_family = Family.new
  @fake_person.stubs(:families).returns([ fake_family ])
end

def set_up_user_finding_in_authorization
  fake_user = User.new(:person => @fake_person)
  stub_find_user_in_session_for_controller fake_user
  fake_user.stubs(:authorized?).returns(true)
end

def set_up_person_finding_by_id
  Person.stubs(:find_by_id).returns(@fake_person)
end
