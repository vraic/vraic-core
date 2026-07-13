require "test_helper"

class NewslettersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @account = accounts(:one)
    sign_in_as(@user)
    @newsletter = newsletters(:one) if defined?(newsletters)
    # If fixtures for newsletters don't exist yet, I'll create one manually in setup or use a mock
    @newsletter ||= Newsletter.create!(account: @account, subject: "Test Newsletter", content: "Hello world", target: :everyone)
  end

  test "should get index" do
    get newsletters_url
    assert_response :success
  end

  test "should get new" do
    get new_newsletter_url
    assert_response :success
  end

  test "should create newsletter" do
    assert_difference("Newsletter.count") do
      post newsletters_url, params: { newsletter: { content: "New content", subject: "New subject", target: "customers" } }
    end

    assert_redirected_to newsletter_url(Newsletter.last)
  end

  test "should show newsletter" do
    get newsletter_url(@newsletter)
    assert_response :success
  end

  test "should get edit" do
    get edit_newsletter_url(@newsletter)
    assert_response :success
  end

  test "should update newsletter" do
    patch newsletter_url(@newsletter), params: { newsletter: { content: "Updated content", subject: "Updated subject", target: "suppliers" } }
    assert_redirected_to newsletter_url(@newsletter)
    @newsletter.reload
    assert_equal "Updated subject", @newsletter.subject
  end

  test "should destroy newsletter" do
    assert_difference("Newsletter.count", -1) do
      delete newsletter_url(@newsletter)
    end

    assert_redirected_to newsletters_url
  end

  test "should deliver newsletter" do
    assert_enqueued_with(job: NewsletterDeliveryJob, args: [ @newsletter ]) do
      post deliver_newsletter_url(@newsletter)
    end
    assert_redirected_to newsletter_url(@newsletter)
    assert_not_nil @newsletter.reload.sent_at
  end
end
