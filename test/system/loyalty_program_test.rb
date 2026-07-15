require "application_system_test_case"

class LoyaltyProgramTest < ApplicationSystemTestCase
  setup do
    @account = accounts(:one)
    @manager = users(:one) # Manager of account one
    @customer_user = users(:three) # customer@example.com
    @customer = customers(:one) # customer@example.com in account one

    # Ensure customer is linked to user and location is a collection point
    @customer.update!(user: @customer_user)
    @customer.loyalty_card&.destroy
    locations(:one).update!(collection_point: true)
  end

  test "full loyalty program lifecycle" do
    # 1. Manager configures loyalty program
    login_as(@manager)
    select_account(@account.name)
    visit edit_account_path(@account)
    click_on "Loyalty Program"

    check "Enable Loyalty Program"
    fill_in "Points earned per £1 spent", with: "1"
    fill_in "Redemption value per point", with: "0.10"
    click_on "Save Loyalty Settings"

    assert_text "Account was successfully updated."

    # 2. Customer enrolls
    logout
    login_as(@customer_user)
    select_account(@account.name)

    visit dashboard_path
    assert_text "Join our Loyalty Program!"
    click_on "Enroll Now"

    assert_text "You've successfully enrolled in the loyalty program!"
    assert_text "Current Balance: 0 points"

    # 3. Customer earns points (simulated by manager marking order complete)
    # Create an order first
    visit new_order_path

    # Select product and location in the first item row
    within ".nested-form-wrapper" do
      select "Ribeye Steak", from: "Product"
      select "Shop Floor", from: "Collection Point"
      fill_in "Quantity", with: "5" # Price is 19.99 * 5 = 99.95
    end
    click_on "Create Order"

    assert_text "Order #", wait: 10
    order_number = page.text.match(/Order #([0-9A-Z]{6})/)[1]
    order = Order.find_by!(number: order_number)

    logout

    # Manager completes the order
    login_as(@manager)
    select_account(@account.name)
    visit order_path(order)
    click_on "Mark as Awaiting Collection"
    click_on "Mark as Complete"
    assert_text "Order has been completed."
    logout

    # 4. Customer checks balance and redeems points
    login_as(@customer_user)
    select_account(@account.name)
    visit dashboard_path
    # 99.95 spent = 99 points (assuming 1 point per £1 spent, rounded down by currency_to_points)
    assert_text "Current Balance: 99 points"

    visit new_order_path
    # Should see loyalty redemption section
    assert_text "99 points available"
    fill_in "order_loyalty_points_redeemed", with: "50"

    within ".nested-form-wrapper" do
      select "Ribeye Steak", from: "Product"
      select "Shop Floor", from: "Collection Point"
      fill_in "Quantity", with: "1" # Total 19.99 - 5.00 = 14.99
    end
    click_on "Create Order"

    assert_text "Loyalty Discount (50 points)"
    assert_text "- £5.00"
    assert_text "£14.99" # Final total

    # Check balance decreased
    visit dashboard_path
    assert_text "Current Balance: 49 points"
  end

  private

  # Use helpers from ApplicationSystemTestCase
end
