require "test_helper"

class GlobalAdminTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:administrator)
    @account = accounts(:one)
  end

  test "admin can select an account and create an inventory item" do
    sign_in_as(@admin)

    # Select an account
    patch managed_account_path, params: { account_id: @account.id }
    assert_redirected_to root_path
    follow_redirect!
    assert_equal @account.id, session[:managed_account_id]

    # Now create an inventory item
    assert_difference("InventoryItem.count") do
      post inventory_items_path, params: {
        inventory_item: {
          name: "Admin Item",
          price: 10.00,
          unit_type: "per_unit"
        }
      }
    end

    item = InventoryItem.last
    assert_equal @account.id, item.account_id
    assert_redirected_to inventory_item_path(item)
  end

  test "admin without selected account sees all items" do
    sign_in_as(@admin)

    # Ensure no managed account
    delete managed_account_path

    get inventory_items_path
    assert_response :success
    # In global mode, it should show items from all accounts
  end

  test "admin can see all navigation links" do
    sign_in_as(@admin)
    get dashboard_path
    assert_select "nav" do
      assert_select "a", text: /Tasks/
      assert_select "a", text: /Customers/
      assert_select "a", text: /Inventory/
      assert_select "a", text: /Orders/
      assert_select "a", text: /Settings/
    end
  end

  test "admin cannot create an inventory item without selecting an account" do
    sign_in_as(@admin)

    # Ensure no managed account
    delete managed_account_path

    # This should fail or at least not create an item with nil account_id
    # depending on database constraints and acts_as_tenant validation.
    assert_no_difference("InventoryItem.count") do
      post inventory_items_path, params: {
        inventory_item: {
          name: "Should Fail",
          price: 10.00,
          unit_type: "per_unit"
        }
      }
    end

    assert_response :unprocessable_entity
  end
  test "admin can switch back to global view" do
    sign_in_as(@admin)
    patch managed_account_path, params: { account_id: @account.id }

    patch managed_account_path, params: { account_id: "" }
    assert_redirected_to root_path
    assert_nil session[:managed_account_id]
  end
end
