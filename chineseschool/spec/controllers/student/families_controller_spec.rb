require 'spec_helper'

describe Student::FamiliesController, 'checking authorization' do
  before(:each) do
    stub_check_authentication_in @controller
    set_up_fake_person
    set_up_user_finding_in_authorization
    set_up_family_finding_by_id
  end

  it 'should not redirect if the user is the parent one of the family' do
    @fake_family.parent_one = @fake_person
    get :edit_address, {:id => @fake_family_id}
    response.should_not be_redirect
  end

  it 'should not redirect if the user is the parent two of the family' do
    @fake_family.parent_two = @fake_person
    get :edit_address, {:id => @fake_family_id}
    response.should_not be_redirect
  end

  it 'should set flash notice if editing family address is not allowed' do
    get :edit_address, {:id => rand(100000)}
    flash[:notice].should == 'Access to requested family data not authorized'
  end

  it 'should redirect to home page if editing family address is not allowed' do
    get :edit_address, {:id => rand(100000)}
    response.should redirect_to(:controller => '/home', :action => :index)
  end
end

describe Student::FamiliesController, 'editing family address' do
  # This controller uses template from other controllers, so we force rendering
  # of views in these test to make sure there are no path issues for partials
  integrate_views

  before(:each) do
    stub_check_authentication_in @controller
    set_up_fake_person
    set_up_user_finding_in_authorization
    set_up_family_finding_by_id
    @controller.stubs(:action_authorized?).returns(true)
  end

  it 'should re-use view template for /registration/families/edit_address' do
    get :edit_address, {:id => @fake_family_id}
    response.should render_template('registration/families/edit_address.html.erb')
  end
end


def set_up_fake_person
  @fake_person = Person.new
  @fake_person.id = rand 100000
end

def set_up_user_finding_in_authorization
  fake_user = User.new(:person => @fake_person)
  stub_find_user_in_session_for_controller fake_user
  fake_user.stubs(:authorized?).returns(true)
end

def set_up_family_finding_by_id
  @fake_family = Family.new
  @fake_family_id = rand 100000
  @fake_family.id = @fake_family_id
  Family.stubs(:find_by_id).returns(@fake_family)
end
