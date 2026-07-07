require "application_system_test_case"

class OrdersTest < ApplicationSystemTestCase
  setup do
    @admin = users(:administrator)
    @item = inventory_items(:one) # Ribeye Steak, 19.99, 10 units in Storage Room
    @location = locations(:one) # Storage Room
  end

  test "staff member sees auto-filled price and stock limit" do
    login_as @admin
    visit new_order_url

    # Add an order item
    click_on "Add Item"

    within ".nested-form-wrapper" do
      # Select product
      select @item.display_name, from: "Product"

      # Check if price is auto-filled
      assert_field "Unit Price", with: "19.99"

      # Select location
      select @location.name, from: "Location"

      # Check if quantity max is set to 10
      assert_selector "input[name*='quantity'][max='10']"

      # Change quantity to 5
      fill_in "Quantity", with: "5"
    end

    click_on "Create Order"

    assert_text "Order was successfully created"
  end

  private

  def login_as(user)
    visit new_session_url
    fill_in "Email", with: user.email_address
    fill_in "Password", with: "password"
    click_button "Sign in"
    assert_text "Dashboard"
  end
end
