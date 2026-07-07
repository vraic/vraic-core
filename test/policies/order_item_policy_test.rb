require 'test_helper'

class OrderItemPolicyTest < ActiveSupport::TestCase
  setup do
    @admin = users(:one)
    @customer = users(:three)
    @order_item = order_items(:one)
    Current.account = accounts(:one)
  end

  def test_scope
    scope = OrderItemPolicy::Scope.new(@admin, OrderItem).resolve
    assert_includes scope, @order_item
  end

  def test_show
    assert OrderItemPolicy.new(@admin, @order_item).show?
  end

  def test_create
    assert OrderItemPolicy.new(@admin, OrderItem).create?
  end

  def test_update
    assert OrderItemPolicy.new(@admin, @order_item).update?
  end

  def test_destroy
    assert OrderItemPolicy.new(@admin, @order_item).destroy?
  end
end
