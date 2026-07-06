require "test_helper"

class CustomerTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:one)
    ActsAsTenant.current_tenant = @account
  end

  test "has prefixed id" do
    customer = customers(:one)
    assert_match(/^cust_/, customer.to_param)
    assert_equal customer, Customer.find_by_prefix_id(customer.to_param)
  end

  test "soft deletes customer" do
    customer = customers(:one)
    customer.destroy
    assert_not_nil customer.deleted_at
    assert_nil Customer.find_by(id: customer.id)
    assert_not_nil Customer.with_deleted.find_by(id: customer.id)
  end

  test "really deletes customer" do
    customer = customers(:one)
    customer.destroy_fully!
    assert_nil Customer.with_deleted.find_by(id: customer.id)
  end

  test "anonymises customer fields" do
    customer = customers(:one)
    original_name = customer.name
    original_email = customer.email_address

    assert customer.anonymise!

    assert_not_equal original_name, customer.reload.name
    assert_not_equal original_email, customer.reload.email_address
  end

  test "validates name presence" do
    customer = Customer.new(name: "")
    assert_not customer.valid?
    assert_includes customer.errors[:name], "can't be blank"
  end
end
