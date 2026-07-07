require "test_helper"

class OrderMailerTest < ActionMailer::TestCase
  test "order_received" do
    order = orders(:one)
    mail = OrderMailer.order_received(order)
    assert_equal "Order Received - ##{order.prefix_id}", mail.subject
    assert_equal [ order.customer.email_address ], mail.to
    assert_match "Order Received", mail.body.encoded
  end

  test "order_awaiting_collection" do
    order = orders(:one)
    mail = OrderMailer.order_awaiting_collection(order)
    assert_equal "Your Order is Ready for Collection - ##{order.prefix_id}", mail.subject
    assert_equal [ order.customer.email_address ], mail.to
    assert_match "Ready for Collection", mail.body.encoded
  end
end
