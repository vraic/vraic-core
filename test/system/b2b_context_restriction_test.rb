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

    # Also setup Account Two as a supplier for Account One
    ActsAsTenant.with_tenant(@account_one) do
      Supplier.create!(
        name: @store.name,
        email_address: @admin_user.email_address,
        supplier_account: @store
      )
    end
  end

  test "account admin switching to a joined store sees restricted view" do
    login_as @admin_user

    # Start with Account One
    select_account("Account One")

    # Switch to Account Two via Suppliers table
    within "#suppliers-table" do
      assert_text "Account Two"
      row = find("tr", text: "Account Two")
      within row do
        click_on "Visit Shop & Order"
      end
    end

    assert_current_path new_order_path
    assert_text "New order"
    assert_text "Account Two"

    # Should NOT see staff-only sidebar items
    within "#desktop-sidebar-main-nav" do
      assert_no_text "Tasks"
      assert_no_text "Customers"
      assert_no_text "Suppliers"
      assert_no_text "Inventory"
      assert_no_text "Reports"
    end

    # Should NOT see "Stores joined by Account Two" on dashboard
    assert_no_text "Stores joined by Account Two"

    # Should NOT see "Join a Store" on dashboard (since they have > 1 account)
    assert_no_text "Join a Store"

    # Should NOT see "Supply a Store" on dashboard
    assert_no_text "Supply a Store"
  end
end
