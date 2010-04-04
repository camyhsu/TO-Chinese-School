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

describe Registration::PeopleController, 'processing find families for one family' do
  before(:each) do
    stub_check_authentication_and_authorization_in @controller
    @fake_id = rand 100
    @fake_person = Person.new
    @fake_family = Family.new
    @fake_family.id = rand 100
    @fake_families = [ @fake_family ]
  end

  it 'should find all families for the person' do
    Person.expects(:find_by_id).with(@fake_id).once.returns(@fake_person)
    @fake_person.expects(:families).once.returns(@fake_families)
    invoke_find_families_for
  end

  it 'should redirect to family controller to show if only one family is found' do
    Person.expects(:find_by_id).with(@fake_id).once.returns(@fake_person)
    @fake_person.expects(:families).once.returns(@fake_families)
    invoke_find_families_for
    response.should be_redirect
    response.should redirect_to(:controller => 'registration/families', :action => 'show', :id => @fake_family.id.to_s)
  end

  def invoke_find_families_for
    get :find_families_for, { :id => @fake_id }
  end
end

describe Registration::PeopleController, 'processing find families for two or more families' do
  before(:each) do
    stub_check_authentication_and_authorization_in @controller
    @fake_id = rand 100
    @fake_person = Person.new
    @fake_family_one = Family.new
    @fake_family_one.id = rand 100
    @fake_family_two = Family.new
    @fake_family_two.id = rand 100
    @fake_families = [ @fake_family_one, @fake_family_two ]
  end

  it 'should find all families for the person' do
    Person.expects(:find_by_id).with(@fake_id).once.returns(@fake_person)
    @fake_person.expects(:families).once.returns(@fake_families)
    invoke_find_families_for
  end

  it 'should redirect to family controller to show the list of linked families' do
    Person.expects(:find_by_id).with(@fake_id).once.returns(@fake_person)
    @fake_person.expects(:families).once.returns(@fake_families)
    invoke_find_families_for
    response.should be_redirect
    response.should redirect_to(:controller => 'registration/families', :action => 'show_list', :id => id_array_for(@fake_families))
  end

  def invoke_find_families_for
    get :find_families_for, { :id => @fake_id }
  end

  def id_array_for(families)
    families.collect { |family| family.id }
  end
end
