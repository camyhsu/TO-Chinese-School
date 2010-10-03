require 'test_helper'

class SigninMailerTest < ActionMailer::TestCase
  test "registration_invitation" do
    @expected.subject = 'SigninMailer#registration_invitation'
    @expected.body    = read_fixture('registration_invitation')
    @expected.date    = Time.now

    assert_equal @expected.encoded, SigninMailer.create_registration_invitation(@expected.date).encoded
  end

end
