require "test_helper"

class AccountUserSecurityTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:one)
    @admin = users(:one)
    sign_in_as @admin
  end

  test "creating a new account user by email creates a user with a secure password" do
    email = "newuser_#{Time.now.to_i}@example.com"
    assert_difference -> { User.count } => 1, -> { AccountUser.count } => 1 do
      post account_account_users_path(@account), params: { 
        email_address: email, 
        account_user: { user_role: "store_staff" } 
      }
    end

    user = User.find_by(email_address: email)
    # We can verify it's set and secure.
    assert user.password_digest.present?
    assert user.prefers_email_login?
  end
end
