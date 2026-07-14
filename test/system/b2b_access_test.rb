require "application_system_test_case"

class B2bAccessTest < ApplicationSystemTestCase
  setup do
    @admin = users(:one) # Admin of Account One
    @account_one = accounts(:one)
    @store = accounts(:four) # Store (Account Four)
    # Account One is a customer of Account Four (via b2b_customer fixture)

    # Ensure Account Four is also a supplier for Account One so it shows in the table
    ActsAsTenant.with_tenant(@account_one) do
      Supplier.find_or_create_by!(supplier_account: @store) do |s|
        s.name = @store.name
        s.email_address = "b2b@example.com"
      end
    end
  end

  test "user can access a store their account has joined" do
    login_as @admin
    visit dashboard_path

    # Verify we see the store in the suppliers table
    within "#suppliers-table" do
      assert_text "Account Four"
      row = find("tr", text: "Account Four")
      within row do
        click_on "Visit Shop & Order"
      end
    end

    assert_current_path new_order_path
    assert_text "New order"
    assert_text "Account Four"

    # Verify an AccountUser was created for us in Account Four
    assert AccountUser.unscoped.exists?(user: @admin, account: @store, user_role: :customer)
  end
end
