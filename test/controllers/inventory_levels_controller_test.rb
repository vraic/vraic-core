require "test_helper"

class InventoryLevelsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @inventory_item = inventory_items(:one)
    @location = locations(:one)
    sign_in_as(@user)
  end

  test "should create or update inventory level" do
    assert_difference("InventoryLevel.count", 0) do # Already exists in fixtures
      post inventory_item_inventory_levels_url(@inventory_item), params: { location_id: @location.id, quantity: 20 }
    end
    assert_redirected_to inventory_item_url(@inventory_item)
    assert_equal 20, InventoryLevel.find_by(inventory_item: @inventory_item, location: @location).quantity
  end

  test "should transfer stock" do
    to_location = locations(:two)
    # Ribeye has 10 in location one (from fixtures)
    assert_difference -> { InventoryLevel.find_by(inventory_item: @inventory_item, location: @location).quantity } => -5,
                      -> { InventoryLevel.find_or_initialize_by(inventory_item: @inventory_item, location: to_location).quantity } => 5 do
      post transfer_inventory_item_inventory_levels_url(@inventory_item), params: { from_location_id: @location.id, to_location_id: to_location.id, transfer_quantity: 5 }
    end
    assert_redirected_to inventory_item_url(@inventory_item)
  end

  test "should not transfer stock if insufficient" do
    to_location = locations(:two)
    post transfer_inventory_item_inventory_levels_url(@inventory_item), params: { from_location_id: @location.id, to_location_id: to_location.id, transfer_quantity: 100 }
    assert_redirected_to inventory_item_url(@inventory_item)
    assert_match "Insufficient stock", flash[:alert]
  end
end
