require "test_helper"

class AccountUsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @administrator = users(:administrator)
    @account_user = account_users(:one)
    @account = @account_user.account
    @unassigned_user = users(:unassigned)

    sign_in_as(@administrator)
  end

  test "should get index" do
    get account_account_users_url(@account)
    assert_response :success
  end

  test "should get new" do
    get new_account_account_user_url(@account)
    assert_response :success
  end

  test "should create account_user" do
    assert_difference("AccountUser.count") do
      post account_account_users_url(@account), params: {
        email_address: "newuser@example.com",
        account_user: { user_role: "store_staff" }
      }
    end

    assert_redirected_to account_url(@account)
  end

  test "should show account_user" do
    get account_user_url(@account_user)
    assert_response :success
  end

  test "should get edit" do
    get edit_account_user_url(@account_user)
    assert_response :success
  end

  test "should update account_user" do
    patch account_user_url(@account_user), params: { account_user: { user_role: "store_staff" } }
    assert_redirected_to account_url(@account)
  end

  test "should destroy account_user" do
    assert_difference("AccountUser.count", -1) do
      delete account_user_url(@account_user)
    end

    assert_redirected_to account_url(@account)
  end
end
