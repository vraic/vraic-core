require "application_system_test_case"

class InventoryFlowTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @account = accounts(:one)
    login_as @user
  end

  test "creating a parent item, then a variant, and adjusting stock" do
    visit inventory_items_url
    assert_selector "h1", text: "Inventory"
    click_on "New Item"

    assert_selector "h1", text: "New inventory item"
    fill_in "inventory_item_name", with: "Test Product"
    fill_in "inventory_item_description", with: "Product description"
    fill_in "inventory_item_price", with: "19.99"
    select "Meat", from: "Group"
    click_button "Create Inventory item"

    assert_text "Inventory item was successfully created"
    assert_text "Test Product"
    assert_text "£19.99"

    parent = InventoryItem.find_by!(name: "Test Product")
    click_on "Add Variant"

    assert_selector "h1", text: "New inventory item"
    fill_in "inventory_item_name", with: "Small Pack"
    fill_in "inventory_item_price", with: "9.99"
    select "Per weight", from: "Pricing Unit"
    fill_in "inventory_item_weight_value", with: "250"
    fill_in "inventory_item_weight_unit", with: "g"
    click_button "Create Inventory item"

    assert_text "Inventory item was successfully created"
    assert_text "Small Pack"
    assert_text "£9.99"

    # Adjust stock
    select "Storage Room", from: "Location"
    fill_in "New Total Quantity", with: "50"
    click_on "Update Stock"

    assert_text "Stock was successfully adjusted"
    assert_text "50"

    # Move stock
    select "Storage Room", from: "From Location"
    select "Shop Floor", from: "To Location"
    fill_in "Quantity to Move", with: "10"
    click_on "Transfer"

    assert_text "Successfully transferred stock"
    assert_text "40" # Remaining in Storage Room
    assert_text "10" # New on Shop Floor
  end

  private

  def login_as(user)
    visit new_session_url
    fill_in "Email", with: user.email_address
    fill_in "Password", with: "password"
    click_on "Sign in"
    assert_text "Dashboard"
    assert_current_path dashboard_path
  end
end
