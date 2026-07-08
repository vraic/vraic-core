require "test_helper"

class SupportRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:administrator)
    @store_manager = users(:one)
    @account = accounts(:one)
    @support_request = support_requests(:one)
  end

  test "should get index as admin" do
    sign_in_as @admin
    get support_requests_url
    assert_response :success
  end

  test "should get index as store manager" do
    sign_in_as @store_manager
    get support_requests_url
    assert_response :success
  end

  test "should get new" do
    sign_in_as @store_manager
    get new_support_request_url
    assert_response :success
  end

  test "should create support_request" do
    sign_in_as @store_manager
    assert_difference("SupportRequest.count") do
      post support_requests_url, params: { support_request: { message: "New help request" } }
    end
    assert_redirected_to support_requests_url
  end

  test "should accept support_request" do
    sign_in_as @admin
    patch support_request_url(@support_request), params: { support_request: { status: "accepted" } }
    assert_redirected_to support_requests_url
    @support_request.reload
    assert @support_request.accepted?
    assert @support_request.expires_at.present?
  end

  test "should extend support_request" do
    @support_request.grant_authorization!
    sign_in_as @admin
    post extend_support_request_url(@support_request), params: { duration: 24, unit: "hours" }
    assert_redirected_to support_requests_url
    # Verify expiration increased
  end
end
