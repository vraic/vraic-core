# Preview all emails at http://localhost:3000/rails/mailers/order_mailer
class OrderMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/order_mailer/order_received
  def order_received
    OrderMailer.order_received
  end

  # Preview this email at http://localhost:3000/rails/mailers/order_mailer/order_awaiting_collection
  def order_awaiting_collection
    OrderMailer.order_awaiting_collection
  end
end
