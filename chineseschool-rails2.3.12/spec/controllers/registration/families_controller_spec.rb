require 'spec_helper'

describe Registration::FamiliesController, 'displaying one family' do
  before(:each) do
    stub_check_authentication_and_authorization_in @controller
    @fake_id = rand 100
    @fake_family = Family.new
  end

  it 'should find one family' do
    Family.expects(:find_by_id).with(@fake_id).once.returns(@fake_family)
    invoke_get_show
  end
  
  it 'should assign family found' do
    Family.expects(:find_by_id).with(@fake_id).once.returns(@fake_family)
    invoke_get_show
    assigns[:family].should == @fake_family
  end

  it 'should be success' do
    invoke_get_show
    response.should be_success
  end

  it 'should render show template' do
    invoke_get_show
    response.should render_template('registration/families/show.html.erb')
  end

  it 'should respond to correct route' do
    { :get => "/chineseschool/registration/families/show/#{@fake_id}" }.should route_to( :controller => 'registration/families', :action => 'show', :id => @fake_id.to_s )
  end


  def invoke_get_show
    get :show, { :id => @fake_id }
  end
end
