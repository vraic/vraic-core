class NewsletterDeliveryJob < ApplicationJob
  queue_as :default

  def perform(newsletter)
    recipients = case newsletter.target
    when "everyone"
                   # Combine customers and suppliers, unique by email
                   customers = newsletter.account.customers.where(subscribed_to_newsletter: true).to_a
                   suppliers = newsletter.account.suppliers.where(subscribed_to_newsletter: true).to_a
                   (customers + suppliers).uniq { |r| r.email_address }
    when "customers"
                   newsletter.account.customers.where(subscribed_to_newsletter: true)
    when "suppliers"
                   newsletter.account.suppliers.where(subscribed_to_newsletter: true)
    end

    recipients.each do |recipient|
      NewsletterMailer.with(newsletter: newsletter, recipient: recipient).newsletter_email.deliver_later
    end
  end
end
