require "test_helper"

class OrderItemTest < ActiveSupport::TestCase
  test "deducts stock when created" do
    item = inventory_items(:one)
    loc = locations(:one)
    level = inventory_levels(:one) # item: one, loc: one
    initial_qty = level.quantity

    OrderItem.create!(order: orders(:one), inventory_item: item, location: loc, quantity: 5)

    assert_equal initial_qty - 5, level.reload.quantity
  end

  test "returns stock when destroyed" do
    item = inventory_items(:one)
    loc = locations(:one)
    level = inventory_levels(:one)

    order_item = OrderItem.create!(order: orders(:one), inventory_item: item, location: loc, quantity: 5)
    initial_qty = level.reload.quantity

    order_item.destroy
    assert_equal initial_qty + 5, level.reload.quantity
  end

  test "adjusts stock when quantity is updated" do
    item = inventory_items(:one)
    loc = locations(:one)
    level = inventory_levels(:one)

    order_item = OrderItem.create!(order: orders(:one), inventory_item: item, location: loc, quantity: 5)
    initial_qty = level.reload.quantity

    order_item.update!(quantity: 8)
    assert_equal initial_qty - 3, level.reload.quantity
  end

  test "validates sufficient stock" do
    item = inventory_items(:one) # has 10 in stock
    loc = locations(:one)

    order_item = OrderItem.new(order: orders(:one), inventory_item: item, location: loc, quantity: 11)
    assert_not order_item.valid?
    assert_includes order_item.errors[:quantity], "cannot exceed available stock at this location (10 units)"
  end
end
