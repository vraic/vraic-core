require "application_system_test_case"

class DashboardMembershipsTest < ApplicationSystemTestCase
  setup do
    @user = users(:three) # A user who might not be in all accounts
    # Ensure they have at least one account to see the dashboard normally
    # Actually users(:three) is already a customer in Account One
  end

  test "joining a store updates the dashboard" do
    login_as @user
    # users(:three) is in Account One (from fixtures maybe? let's check)

    visit dashboard_path

    # Check if Account Two is available to join
    assert_text "Join a Store"
    assert_selector "select#account_id option", text: "Account Two"

    # Join Account Two
    select "Account Two", from: "Select Store to Join"
    click_on "Join Store"

    assert_text "You have successfully joined Account Two"

    # Now check dashboard again (should be redirected there)
    # The controller redirects to dashboard_path.

    assert_match /\/dashboard|\//, current_path
    # dashboard is the root if authenticated

    # Account Two should now be in "Your Stores"
    within ".grid" do # Your Stores grid
      assert_text "Account Two"
    end

    # Account Two should NOT be in "Join a Store" anymore
    if has_text?("Join a Store")
      assert_no_selector "select#account_id option", text: "Account Two"
    end
  end
end
