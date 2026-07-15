require "application_system_test_case"

class LoyaltyDashboardVisibilityTest < ApplicationSystemTestCase
  setup do
    @account = accounts(:one)
    @customer_user = users(:three) # customer@example.com
    @customer = customers(:one)
    @customer.update!(user: @customer_user)

    @loyalty_program = @account.loyalty_program || @account.create_loyalty_program(
      active: true,
      currency_to_points_ratio: 1,
      points_to_currency_ratio: 0.1
    )
  end

  test "loyalty panel is hidden when program is inactive and user has no card" do
    @loyalty_program.update!(active: false)
    # Ensure no loyalty card exists for this customer
    @customer.loyalty_card&.destroy

    login_as(@customer_user)
    select_account(@account.name)

    visit dashboard_path
    assert_no_selector "#loyalty-program"
    assert_no_text "Loyalty Program"
    assert_no_text "Loyalty program is currently unavailable for this store."
  end

  test "loyalty panel is visible when user has a card even if program is inactive" do
    @loyalty_program.update!(active: false)
    @customer.create_loyalty_card!(loyalty_program: @loyalty_program)

    login_as(@customer_user)
    select_account(@account.name)

    visit dashboard_path
    assert_selector "#loyalty-program"
    assert_text "Loyalty Program"
    assert_text "#{@account.name} Loyalty Card"
  end

  test "loyalty panel is visible when program is active even if user has no card" do
    @loyalty_program.update!(active: true)
    @customer.loyalty_card&.destroy

    login_as(@customer_user)
    select_account(@account.name)

    visit dashboard_path
    assert_selector "#loyalty-program"
    assert_text "Loyalty Program"
    assert_text "Join our Loyalty Program!"
  end
end
