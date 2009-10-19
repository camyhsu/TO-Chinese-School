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

  it 'should respond to routes' do
    { :get => '/chineseschool/signin' }.should route_to( :controller => 'signin', :action => 'index' )
  end
end


describe SigninController, 'handling post request for singin' do
  it 'should authenticate username and password'
end