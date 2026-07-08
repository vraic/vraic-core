require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "two_factor_code" do
    user = users(:one)
    mail = UserMailer.two_factor_code(user, "12345678")
    assert_equal "Your 2FA Verification Code", mail.subject
    assert_equal [ user.email_address ], mail.to
    assert_match "12345678", mail.body.encoded
  end
end
