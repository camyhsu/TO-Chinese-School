require 'spec_helper'

describe HomeController do
  before(:each) do
    stub_find_user_in_session_for_controller
  end

  it 'should not check authorization' do
    stub_check_authentication_in controller
    controller.expects(:check_authorization).never
    get :index
  end
end
