require "test_helper"

class AdminCustomersTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:administrator)
    sign_in_as(@admin)
  end

  test "admin should see all accounts in the dropdown when creating a new customer" do
    get new_customer_url
    assert_response :success

    # Check if the dropdown exists and has options
    assert_select "select#customer_account_id" do
      assert_select "option", minimum: 2 # We have 'one' and 'two' in fixtures
    end
  end
end
