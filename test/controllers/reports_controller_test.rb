require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:administrator)
    @store_manager = users(:one)
    @account = accounts(:one)
  end

  test "should get index as admin" do
    sign_in_as @admin
    select_account(@account)
    get reports_url
    assert_response :success
  end

  test "should get index as store manager" do
    sign_in_as @store_manager
    get reports_url
    assert_response :success
  end

  test "should redirect to root for non-staff" do
    # Assuming users(:three) is a customer in Account One
    sign_in_as users(:three)
    get reports_url
    assert_redirected_to root_url
  end

  private

  def select_account(account)
    patch managed_account_url, params: { account_id: account.id }
  end
end
