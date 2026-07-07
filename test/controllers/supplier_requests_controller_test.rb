require "test_helper"

class SupplierRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @receiver = accounts(:two)
    @request = supplier_requests(:one)
    @account = accounts(:one)
    sign_in_as(@user)
    patch managed_account_url, params: { account_id: @account.id }
  end

  test "should get index" do
    get supplier_requests_url
    assert_response :success
  end

  test "should get new" do
    get new_supplier_request_url
    assert_response :success
  end

  test "should create supplier_request" do
    assert_difference("SupplierRequest.count") do
      post supplier_requests_url, params: { supplier_request: { receiver_account_id: @receiver.id } }
    end
    assert_redirected_to supplier_requests_url
  end

  test "should approve supplier_request" do
    # Request where current account is receiver
    request = SupplierRequest.create!(sender_account: @receiver, receiver_account: accounts(:one))
    patch supplier_request_url(request), params: { status: :approved }
    assert_redirected_to supplier_requests_url
    assert request.reload.approved?
  end

  test "should destroy supplier_request" do
    request = SupplierRequest.create!(sender_account: @account, receiver_account: @receiver)
    assert_difference("SupplierRequest.count", -1) do
      delete supplier_request_url(request)
    end
    assert_redirected_to supplier_requests_url
  end
end
