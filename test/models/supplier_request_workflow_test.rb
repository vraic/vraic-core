require "test_helper"

class SupplierRequestWorkflowTest < ActiveSupport::TestCase
  setup do
    @sender = accounts(:one)
    @receiver = accounts(:two)
  end

  test "approving a supplier request creates bidirectional relationships" do
    request = SupplierRequest.create!(
      sender_account: @sender,
      receiver_account: @receiver,
      status: :pending
    )

    assert_no_difference "Customer.count" do
      assert_no_difference "Supplier.count" do
        request.update!(status: :rejected)
      end
    end

    request.update!(status: :pending)

    assert_difference "Customer.count", 1 do
      assert_difference "Supplier.count", 1 do
        request.update!(status: :approved)
      end
    end

    # Check Customer in Sender account
    customer = Customer.find_by(customer_account: @receiver, account: @sender)
    assert_not_nil customer
    assert_equal @receiver.name, customer.name

    # Check Supplier in Receiver account
    supplier = Supplier.find_by(supplier_account: @sender, account: @receiver)
    assert_not_nil supplier
    assert_equal @sender.name, supplier.name
  end
end
