require "test_helper"

class NewsletterDeliveryJobTest < ActiveJob::TestCase
  setup do
    @account = accounts(:one)
    @customer = customers(:one)
    @customer.update!(subscribed_to_newsletter: true)
    @supplier = suppliers(:one)
    @supplier.update!(subscribed_to_newsletter: true)
    @newsletter = Newsletter.create!(account: @account, subject: "Test", content: "Body", target: :everyone)
  end

  test "performs delivery to everyone" do
    assert_enqueued_emails 2 do
      NewsletterDeliveryJob.perform_now(@newsletter)
    end
  end

  test "performs delivery to customers" do
    @newsletter.update!(target: :customers)
    assert_enqueued_emails 1 do
      NewsletterDeliveryJob.perform_now(@newsletter)
    end
  end

  test "performs delivery to suppliers" do
    @newsletter.update!(target: :suppliers)
    assert_enqueued_emails 1 do
      NewsletterDeliveryJob.perform_now(@newsletter)
    end
  end
end
