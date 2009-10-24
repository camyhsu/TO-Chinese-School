#
# Utility method for setting up sessions
#

def stub_check_authentication_in(controller)
  controller.stubs(:check_authentication)
end