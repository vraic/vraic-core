require "test_helper"

class StoreMembershipTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(name: "New Customer", email_address: "new@example.com", password: "password")
    @account = accounts(:one)
    post session_url, params: { email_address: "new@example.com", password: "password" }
  end

  test "user can join a store from the dashboard" do
    get dashboard_path
    assert_select "h2", "Join a Store"
    assert_select "select[name='account_id']"

    assert_difference "Customer.count", 1 do
      assert_difference "AccountUser.count", 1 do
        post store_memberships_path, params: { account_id: @account.id }
      end
    end

    assert_redirected_to root_path
    follow_redirect!
    assert_redirected_to dashboard_path
    follow_redirect! # To dashboard_path
    assert_equal @account.id, session[:managed_account_id]
    assert_match /You have successfully joined #{@account.name}/, response.body

    # Verify they are now a member
    get dashboard_path
    assert_select "h2", "Your Stores"
    assert_select "h3", @account.name
  end

  test "user cannot join a store they are already a member of" do
    # Join first
    Customer.create!(account: @account, user: @user, name: @user.name, email_address: @user.email_address)

    get dashboard_path
    # Should not show in "Join a Store" dropdown if my logic is correct
    # Account.where.not(id: Current.user.account_ids)
    assert_select "select[name='account_id'] option", { text: @account.name, count: 0 }

    # Try to post anyway
    post store_memberships_path, params: { account_id: @account.id }
    assert_redirected_to dashboard_path
    follow_redirect!
    assert_match /You are already a member of #{@account.name}/, response.body
  end
end
