require "test_helper"

class InventoryVisibilityTest < ActiveSupport::TestCase
  setup do
    @account_a = accounts(:one)
    @account_s = accounts(:two)

    # Make Account S a supplier to Account A
    @supplier = Supplier.create!(
      account: @account_a,
      supplier_account: @account_s,
      name: "Supplier S"
    )

    # Make Account A a customer of Account S
    @customer = Customer.create!(
      account: @account_s,
      customer_account: @account_a,
      name: "Customer A"
    )

    @group_visible = InventoryGroup.create!(account: @account_s, name: "Visible Group")
    @group_visible.customers << @customer

    @group_hidden = InventoryGroup.create!(account: @account_s, name: "Hidden Group")
  end

  test "supplier inventory shows only visible items" do
    item_visible = InventoryItem.create!(account: @account_s, inventory_group: @group_visible, name: "Visible Item")

    item_hidden = InventoryItem.create!(account: @account_s, inventory_group: @group_hidden, name: "Hidden Item")

    # I need to ensure my query in Supplier.inventory_items is correct.
    # It uses: .where("customers.id IS NULL OR customers.id = ?", customer.id)
    # If customers is empty (NULL), it's visible.

    items = @supplier.inventory_items
    assert_includes items, item_visible
    assert_includes items, item_hidden # Because @group_hidden has no specific customers

    # Now restrict @group_hidden to ANOTHER customer
    other_customer = Customer.create!(account: @account_s, name: "Other")
    @group_hidden.customers << other_customer

    items = @supplier.inventory_items
    assert_includes items, item_visible
    assert_not_includes items, item_hidden
  end
end
