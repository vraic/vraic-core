require "test_helper"

class SupplierRequestTest < ActiveSupport::TestCase
  test "approving a request creates relationships in correct tenants" do
    sender = accounts(:one)
    receiver = accounts(:two)

    # Clear any existing relationships from fixtures to be sure
    Customer.unscoped.where(account: sender, customer_account: receiver).destroy_all
    Supplier.unscoped.where(account: receiver, supplier_account: sender).destroy_all

    request = SupplierRequest.create!(sender_account: sender, receiver_account: receiver)

    assert_difference -> { Supplier.unscoped.count } => 1, -> { Customer.unscoped.count } => 1 do
      request.approved!
    end

    # Check Customer (in sender's tenant)
    customer = Customer.unscoped.where(account: sender, customer_account: receiver).last
    supplier = Supplier.unscoped.where(account: receiver, supplier_account: sender).last

    assert_not_nil customer
    assert_equal sender.id, customer.account_id

    # Check Supplier (in receiver's tenant)
    assert_not_nil supplier
    assert_equal receiver.id, supplier.account_id, "Supplier should belong to receiver account"
  end
end
