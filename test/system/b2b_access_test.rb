require "application_system_test_case"

class B2bAccessTest < ApplicationSystemTestCase
  setup do
    @admin = users(:one) # Admin of Account One
    @store = accounts(:four) # Store (Account Four)
    # Account One is a customer of Account Four (via b2b_customer fixture)
  end

  test "user can access a store their account has joined" do
    login_as @admin
    visit dashboard_path

    # Verify we see the B2B section
    assert_text "Stores joined by Account One"
    assert_text "Business memberships represent a wholesale relationship"

    within "#business-stores" do
      assert_text "Account Four"
      click_on "Select"
    end

    assert_text "Switched to Account Four"

    # Verify we are now in Account Four context
    within "#your-stores" do
      assert_text "Account Four"
      # Account Four should be active
      assert_selector "span", text: "Active"
    end

    # Verify an AccountUser was created for us in Account Four
    assert AccountUser.unscoped.exists?(user: @admin, account: @store, user_role: :customer)
  end
end
