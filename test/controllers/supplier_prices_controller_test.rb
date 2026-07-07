require "test_helper"

class SupplierPricesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @item = inventory_items(:one)
    @supplier = suppliers(:one)
    @account = accounts(:one)
    sign_in_as(@user)
    patch managed_account_url, params: { account_id: @account.id }
  end

  test "should create supplier_price" do
    assert_difference("SupplierPrice.count") do
      post inventory_item_supplier_prices_url(@item), params: { supplier_price: { supplier_id: @supplier.id, price: 10.50 } }
    end
    assert_redirected_to inventory_item_url(@item)
  end

  test "should destroy supplier_price" do
    price = SupplierPrice.create!(inventory_item: @item, supplier: @supplier, price: 5.00)
    assert_difference("SupplierPrice.count", -1) do
      delete inventory_item_supplier_price_url(@item, price)
    end
    assert_redirected_to inventory_item_url(@item)
  end
end
