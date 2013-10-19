require 'test_helper'

class SigninMailerTest < ActionMailer::TestCase
  test "account_invitation" do
    @expected.subject = 'SigninMailer#account_invitation'
    @expected.body    = read_fixture('account_invitation')
    @expected.date    = Time.now

    assert_equal @expected.encoded, SigninMailer.create_account_invitation(@expected.date).encoded
  end

end
