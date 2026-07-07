class OrderMailer < ApplicationMailer
  def order_received(order)
    @order = order
    @customer = order.customer
    mail to: @customer.email_address, subject: "Order Received - ##{@order.prefix_id}"
  end

  def order_awaiting_collection(order)
    @order = order
    @customer = order.customer
    mail to: @customer.email_address, subject: "Your Order is Ready for Collection - ##{@order.prefix_id}"
  end
end
