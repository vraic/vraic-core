require "test_helper"

class SuppliersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @supplier = suppliers(:one)
    @account = accounts(:one)
    sign_in_as(@user)
    # Set the tenant
    patch managed_account_url, params: { account_id: @account.id }
  end

  test "should get index" do
    get suppliers_url
    assert_response :success
  end

  test "should get new" do
    get new_supplier_url
    assert_response :success
    assert_select "form"
    assert_select "input[name='supplier[name]']"
    assert_select "input[name='supplier[email_address]']"
    assert_select "select[name='supplier[supplier_account_id]']", 0

    # As admin
    sign_in_as(users(:administrator))
    get new_supplier_url
    assert_response :success
    assert_select "select[name='supplier[supplier_account_id]']", 0
    assert_select "select[name='supplier[account_id]']"
  end

  test "should create supplier" do
    assert_difference("Supplier.count") do
      post suppliers_url, params: { supplier: { name: "New Supplier", email_address: "supp@example.com" } }
    end
    assert_redirected_to supplier_url(Supplier.last)
  end

  test "should show supplier" do
    get supplier_url(@supplier)
    assert_response :success
  end

  test "should get edit" do
    get edit_supplier_url(@supplier)
    assert_response :success
    assert_select "form"
    assert_select "input[name='supplier[name]']"
  end

  test "should update supplier" do
    patch supplier_url(@supplier), params: { supplier: { name: "Updated" } }
    assert_redirected_to supplier_url(@supplier)
    assert_equal "Updated", @supplier.reload.name
  end

  test "should destroy supplier" do
    assert_difference("Supplier.count", -1) do
      delete supplier_url(@supplier)
    end
    assert_redirected_to suppliers_url
  end

  test "should get inventory" do
    get inventory_supplier_url(@supplier)
    assert_response :success
  end
end
