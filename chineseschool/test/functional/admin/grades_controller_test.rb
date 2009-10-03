require 'test_helper'

class Admin::GradesControllerTest < ActionController::TestCase

  test 'index' do
    get :index
    assert_response :success
    assert_template :index
    assert_not_nil assigns['grades']
  end
end
