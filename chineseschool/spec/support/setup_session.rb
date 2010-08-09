#
# Utility method for setting up sessions
#

def stub_check_authentication_in(controller)
  controller.stubs(:check_authentication)
end

def stub_check_authorization_in(controller)
  controller.stubs(:check_authorization)
end

def stub_check_authentication_and_authorization_in(controller)
  stub_check_authentication_in controller
  stub_check_authorization_in controller
end

def stub_find_user_in_session_for_controller
  User.stubs(:find).returns(User.new(:person => Person.new))
end

def stub_find_user_in_session_for_view
  stub_person = Person.new
  stub_person.stubs(:name).returns(random_string 8)
  assigns[:user] = User.new(:person => stub_person)
end
