require 'spec_helper'

describe HomeController do
  it 'should not check authorization' do
    stub_check_authentication_in controller
    controller.expects(:check_authorization).never
    get :index
  end
end
