require "test_helper"

class InventoryItemTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:one)
    ActsAsTenant.current_tenant = @account
    @item = inventory_items(:one)
  end

  test "belongs to account" do
    assert_equal @account, @item.account
  end

  test "soft delete works" do
    # fixture :one has 1 variant (:two), so destroying :one destroys both
    assert_difference("InventoryItem.count", -2) do
      @item.destroy
    end
    assert_includes InventoryItem.only_deleted, @item
  end

  test "really_destroy works" do
    assert_difference("InventoryItem.with_deleted.count", -2) do
      @item.destroy_fully!
    end
  end

  test "display_name for parent" do
    assert_equal "Ribeye Steak", @item.display_name
  end

  test "display_name for variant" do
    variant = inventory_items(:two)
    assert_equal "Ribeye Steak - 500g", variant.display_name
  end

  test "price inheritance" do
    variant = inventory_items(:two)
    # Variant two has price nil in fixtures, should inherit from parent
    assert_equal @item.price, variant.price
  end

  test "price overrides parent if set" do
    variant = inventory_items(:two)
    variant.price = Money.new(2000, "GBP")
    assert_equal Money.new(2000, "GBP"), variant.price
  end

  test "total_quantity" do
    # Ribeye has 10 units in location one (from fixtures)
    assert_equal 10, @item.total_quantity
  end

  test "validates weight if per_weight" do
    item = InventoryItem.new(name: "Test", unit_type: :per_weight)
    assert_not item.valid?
    assert_includes item.errors[:weight_value], "can't be blank"
  end

  test "stock_unit for per_unit" do
    assert_equal "unit", @item.stock_unit
  end

  test "stock_unit for parent per_weight" do
    @item.unit_type = :per_weight
    @item.weight_unit = "kg"
    assert_equal "kg", @item.stock_unit
  end

  test "stock_unit for variant per_weight" do
    variant = inventory_items(:two)
    assert_equal "g", variant.stock_unit
  end

  test "stock_data returns price and stock levels" do
    data = @item.stock_data
    assert_equal @item.price.to_f, data[:price]
    assert_equal 10, data[:total]
    assert_equal({ locations(:one).id => 10 }, data[:locations])
  end
end
