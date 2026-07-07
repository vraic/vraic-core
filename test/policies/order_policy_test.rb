require "test_helper"

class OrderPolicyTest < ActiveSupport::TestCase
  setup do
    @admin = users(:one)
    @customer = users(:three)
    @other_user = users(:two)
    @order = orders(:one)

    # Set current account for policy helpers
    Current.account = accounts(:one)
  end

  def test_scope
    scope = OrderPolicy::Scope.new(@admin, Order).resolve
    assert_includes scope, @order

    scope = OrderPolicy::Scope.new(@customer, Order).resolve
    assert_includes scope, @order # @order.customer is customers(:one), which belongs to users(:three)

    scope = OrderPolicy::Scope.new(@other_user, Order).resolve
    assert_not_includes scope, @order
  end

  def test_show
    assert OrderPolicy.new(@admin, @order).show?
    assert OrderPolicy.new(@customer, @order).show?
    assert_not OrderPolicy.new(@other_user, @order).show?
  end

  def test_create
    assert OrderPolicy.new(@admin, Order).create?
    assert OrderPolicy.new(@customer, Order).create?
  end

  def test_update
    assert OrderPolicy.new(@admin, @order).update?
    assert_not OrderPolicy.new(@customer, @order).update?
  end

  def test_destroy
    assert OrderPolicy.new(@admin, @order).destroy?
    assert_not OrderPolicy.new(@customer, @order).destroy?
  end
end
