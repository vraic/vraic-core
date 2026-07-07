require "application_system_test_case"

class SignupFlowTest < ApplicationSystemTestCase
  test "new user can signup, create a store, and see supplier widget" do
    # 1. Signup
    visit new_user_url
    fill_in "Name", with: "New Store Owner"
    fill_in "Email", with: "owner@example.com"
    fill_in "Password", with: "password123"
    click_button "Create User"

    assert_text "Dashboard"
    assert_text "Welcome, new store owner"
    assert_text "No stores joined yet"

    # 2. Create a Store
    # We need a link to create a store on the dashboard
    click_link "Create a Store"

    fill_in "Name", with: "My Shiny Store"
    fill_in "Address", with: "123 Farm Lane"
    click_button "Create Account"

    assert_text "Account was successfully created"
    
    # 3. Check Dashboard for Supplier Widget
    visit dashboard_path
    assert_text "My Shiny Store"
    assert_text "Role: Admin"
    assert_text "Supply a Store"
  end
end
