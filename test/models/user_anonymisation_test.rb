require "test_helper"

class UserAnonymisationTest < ActiveSupport::TestCase
  test "anonymises user fields" do
    user = users(:one)
    original_email = user.email_address
    original_name = user.name

    assert user.anonymise!

    assert_not_equal original_email, user.reload.email_address
    assert_not_equal original_name, user.reload.name
    assert_equal "ANONYMISED", user.reload.password_digest
    assert_match(/@example.com$/, user.email_address)
  end
end
