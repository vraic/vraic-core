require "test_helper"

class NewsletterAnalyticsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @account = accounts(:one)
    @newsletter = Newsletter.create!(
      account: @account,
      subject: "Analytics Test",
      content: "Content",
      target: "everyone",
      sent_at: Time.current
    )

    @message1 = Ahoy::Message.create!(
      newsletter: @newsletter,
      to: "user1@example.com",
      sent_at: Time.current
    )

    @message2 = Ahoy::Message.create!(
      newsletter: @newsletter,
      to: "user2@example.com",
      sent_at: Time.current,
      opened_at: Time.current
    )

    @message3 = Ahoy::Message.create!(
      newsletter: @newsletter,
      to: "user3@example.com",
      sent_at: Time.current,
      opened_at: Time.current,
      clicked_at: Time.current
    )

    sign_in_as(@user)
  end

  test "newsletter show displays correct stats" do
    get newsletter_url(@newsletter)
    assert_response :success

    assert_select ".text-2xl", text: "3" # Sent
    assert_select ".text-2xl", text: "2" # Opened
    assert_select ".text-2xl", text: "1" # Clicked

    assert_match "66.7% open rate", response.body
    assert_match "33.3% click rate", response.body
  end

  test "newsletter report displays aggregate stats" do
    get report_newsletters_url
    assert_response :success

    assert_select ".text-3xl", text: "3" # Total Sent
    assert_match "66.7%", response.body # Average Open Rate
    assert_match "33.3%", response.body # Average Click Rate
  end
end
