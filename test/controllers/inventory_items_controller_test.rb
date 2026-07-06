require "test_helper"

class InventoryItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one) # Account admin
    @inventory_item = inventory_items(:one)
    sign_in_as(@user)
  end

  test "should get index" do
    get inventory_items_url
    assert_response :success
  end

  test "should get new" do
    get new_inventory_item_url
    assert_response :success
  end

  test "should create inventory_item" do
    assert_difference("InventoryItem.count") do
      post inventory_items_url, params: { inventory_item: { name: "New Item", description: "Desc", price: 10.50, unit_type: "per_unit" } }
    end

    assert_redirected_to inventory_item_url(InventoryItem.last)
    assert_equal accounts(:one).id, InventoryItem.last.account_id
  end

  test "should show inventory_item" do
    get inventory_item_url(@inventory_item)
    assert_response :success
  end

  test "should get edit" do
    get edit_inventory_item_url(@inventory_item)
    assert_response :success
  end

  test "should update inventory_item" do
    patch inventory_item_url(@inventory_item), params: { inventory_item: { name: "Updated Item" } }
    assert_redirected_to inventory_item_url(@inventory_item)
    assert_equal "Updated Item", @inventory_item.reload.name
  end

  test "should destroy inventory_item" do
    # @inventory_item has 1 variant, so -2
    assert_difference("InventoryItem.count", -2) do
      delete inventory_item_url(@inventory_item)
    end

    assert_redirected_to inventory_items_url
  end

  test "should really destroy inventory_item" do
    assert_difference("InventoryItem.with_deleted.count", -2) do
      delete really_destroy_inventory_item_url(@inventory_item)
    end

    assert_redirected_to inventory_items_url
  end

  test "should filter by location" do
    location = locations(:one)
    get inventory_items_url, params: { location_id: location.id }
    assert_response :success
    # Ribeye is in location one in fixtures
    assert_match "Ribeye Steak", response.body
  end

  test "should filter by group" do
    group = inventory_groups(:one)
    get inventory_items_url, params: { inventory_group_id: group.id }
    assert_response :success
    assert_match "Ribeye Steak", response.body
    assert_no_match "Apple", response.body
  end
end
