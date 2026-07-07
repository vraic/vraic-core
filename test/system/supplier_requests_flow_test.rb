require "application_system_test_case"

class SupplierRequestsFlowTest < ApplicationSystemTestCase
  setup do
    @admin = users(:administrator)
    @other_account = accounts(:two)
    login_as @admin
  end

  test "requesting to supply another store from the dashboard" do
    # 1. Select the account that wants to be a supplier
    select_account("Account One")

    visit dashboard_path

    assert_text "Supply a Store"
    assert_text "Request to become a supplier for another farm shop on the platform using Account One"

    within "form[action='/supplier_requests']" do
      select "Account Two", from: "Select Store"
      click_on "Request to Supply"
    end

    assert_text "Supplier request was successfully sent."

    # Verify the request exists
    request = SupplierRequest.last
    assert_equal accounts(:one), request.sender_account
    assert_equal accounts(:two), request.receiver_account
    assert_equal "pending", request.status
  end

  test "cannot see supply section if not an admin" do
    @user = users(:two) # Standard user in Account Two
    login_as @user
    # select_account is not needed because they only have one account, it's auto-selected

    visit dashboard_path
    assert_no_text "Supply a Store"
  end

  test "approved supplier request shows up in both tabs for appropriate accounts" do
    # 1. Account One requests to supply Account Two
    select_account("Account One")
    visit dashboard_path
    within "form[action='/supplier_requests']" do
      select "Account Two", from: "Select Store"
      click_on "Request to Supply"
    end
    assert_text "Supplier request was successfully sent."

    # 2. Account Two approves the request
    select_account("Account Two")
    visit supplier_requests_path
    within "tr", text: "Account One" do
      click_on "Approve"
    end
    assert_text "Supplier request was approved."

    # 3. Check Suppliers in Account Two (Account One should be there as a supplier)
    visit suppliers_path
    within "#suppliers" do
      assert_text "Account One"
    end

    # 4. Check Customers in Account One (Account Two should be there as a business customer)
    select_account("Account One")
    visit customers_path
    within "#customers" do
      assert_text "Account Two"
      assert_text "Business"
    end
  end
end
