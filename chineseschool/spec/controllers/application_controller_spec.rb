require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationController, 'enforcing ssl in production mode' do
  before(:each) do
    @saved_rails_env = RAILS_ENV
    RAILS_ENV = 'production'
  end

  after(:each) do
    RAILS_ENV = @saved_rails_env
  end
  
  it 'should redirect when access through plain http' do
    get :index
    response.should be_redirect
  end

  it 'should redirect to url with prescribed prefix' do
    get :index
    response.should redirect_to('https://www.to-cs.org/chineseschool/application')
  end

  it 'should not redirect when access through ssl' do
    request.expects(:ssl?).once.returns(true)
    get :index
    response.should_not be_redirect
  end
end


describe ApplicationController, 'not enforcing ssl when not in production mode' do
  it 'should not redirect' do
    get :index
    response.should_not be_redirect
  end
end


describe ApplicationController, 'not exposing protected method' do
  it 'should mark ssl_required as a protected method' do
    controller.protected_methods.should include('ssl_required')
  end
end
