require "application_system_test_case"

class InventoryFlowTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    login_as @user
  end

  test "creating a parent item, then a variant, and adjusting stock" do
    visit inventory_items_url
    click_on "New Item"

    fill_in "Name", with: "Test Product"
    fill_in "Description", with: "Product description"
    fill_in "Price", with: "19.99"
    select "Meat", from: "Group"
    click_on "Create Inventory item"

    assert_text "Inventory item was successfully created"
    assert_text "Test Product"
    assert_text "£19.99"

    click_on "Add Variant"
    fill_in "Name", with: "Small Pack"
    fill_in "Price", with: "9.99"
    select "Per weight", from: "Unit type"
    fill_in "Weight value", with: "250"
    fill_in "Weight unit", with: "g"
    click_on "Create Inventory item"

    assert_text "Inventory item was successfully created"
    assert_text "Small Pack"
    assert_text "£9.99"

    # Adjust stock
    select "Store Room", from: "location_id"
    fill_in "quantity", with: "50"
    click_on "Update"

    assert_text "Stock level updated"
    assert_text "50"

    # Move stock
    select "Store Room", from: "From"
    select "Shop Floor", from: "To"
    fill_in "Quantity", with: "10"
    click_on "Transfer"

    assert_text "Successfully moved stock"
    assert_text "40" # Remaining in Store Room
    assert_text "10" # New on Shop Floor
  end

  private

  def login_as(user)
    visit new_session_url
    fill_in "Email address", with: user.email_address
    fill_in "Password", with: "password"
    click_on "Sign in"
  end
end
