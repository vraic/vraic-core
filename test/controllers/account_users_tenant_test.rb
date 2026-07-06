require "test_helper"

class AccountUsersTenantTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @account = accounts(:one)
    @other_account = accounts(:two)
    sign_in_as(@user)
  end

  test "should only show account users for current tenant" do
    get account_users_url
    assert_response :success
    # User one belongs to account one. account_users(:one) is in account one.
    # account_users(:two) is in account two.
    assert_match users(:one).name, response.body
    assert_no_match users(:two).name, response.body
  end

  test "should automatically associate new account_user with current tenant" do
    @unassigned = users(:unassigned)
    assert_difference("AccountUser.count") do
      post account_users_url, params: { account_user: { user_id: @unassigned.id, user_role: "standard" } }
    end

    new_account_user = AccountUser.last
    assert_equal @account.id, new_account_user.account_id
    assert_redirected_to account_user_url(new_account_user)
  end

  test "should not show account dropdown for non-admin" do
    get new_account_user_url
    assert_response :success
    assert_select "select[name='account_user[account_id]']", count: 0
  end

  test "should show account dropdown for admin" do
    sign_in_as(users(:administrator))
    get new_account_user_url
    assert_response :success
    assert_select "select[name='account_user[account_id]']"
  end

  test "admin can create account_user for any account" do
    sign_in_as(users(:administrator))
    @unassigned = users(:unassigned)
    assert_difference("AccountUser.count") do
      post account_users_url, params: { account_user: { account_id: @other_account.id, user_id: @unassigned.id, user_role: "standard" } }
    end

    assert_equal @other_account.id, AccountUser.last.account_id
  end
end
