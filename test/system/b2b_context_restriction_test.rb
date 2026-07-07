require "application_system_test_case"

class B2bContextRestrictionTest < ApplicationSystemTestCase
  setup do
    @admin_user = users(:one) # Admin of Account One
    @account_one = accounts(:one)
    @store = accounts(:two) # Store (Account Two)

    # Setup B2B relationship: Account One is a customer of Account Two
    Customer.create!(
      account: @store,
      customer_account: @account_one,
      name: @account_one.name,
      email_address: @admin_user.email_address
    )
  end

  test "account admin switching to a joined store sees restricted view" do
    login_as @admin_user
    visit dashboard_path

    # Select Account One to start with
    within "form[action='/managed_account']" do
      select "Account One", from: "Select Store"
      click_on "Go"
    end

    assert_text "Switched to Account One"

    # Switch to Account Two
    within "#your-stores" do
      within find("h3", text: "Account Two").find(:xpath, "../..") do
        click_on "Select"
      end
    end

    assert_text "Switched to Account Two"

    # Should NOT see staff-only sidebar items
    within "nav" do
      assert_no_text "Tasks"
      assert_no_text "Customers"
      assert_no_text "Suppliers"
      assert_no_text "Inventory"
      assert_no_text "Reports"
      assert_text "Orders"
    end

    # Should NOT see "Stores joined by Account Two" on dashboard
    assert_no_text "Stores joined by Account Two"

    # Should NOT see "Join a Store" on dashboard (since they have > 1 account)
    assert_no_text "Join a Store"

    # Should NOT see "Supply a Store" on dashboard
    assert_no_text "Supply a Store"
  end
end
