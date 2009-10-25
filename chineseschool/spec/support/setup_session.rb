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
