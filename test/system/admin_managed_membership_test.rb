require "application_system_test_case"

class AdminManagedMembershipTest < ApplicationSystemTestCase
  setup do
    @admin = users(:administrator)
    @managed_account = accounts(:one)
    @store_two = accounts(:two)
    @store_three = accounts(:three)
  end

  test "global admin managing an account can join multiple stores for that account" do
    login_as @admin
    visit dashboard_path

    # Start managing Account One
    select "Account One", from: "Managing Account", match: :first
    click_on "Go", match: :first

    assert_text "Now managing Account One"

    # Join Account Two
    within find("h2", text: "Join a Store").find(:xpath, "..") do
      select "Account Two", from: "Select Store to Join"
      click_on "Join Store"
    end

    assert_text "You have successfully joined Account Two"

    # Verify we are still managing Account One and see Account Two joined
    assert_text "Stores joined by Account One"
    within "#business-stores" do
      assert_text "Account Two"
    end

    # Join Account Three
    within find("h2", text: "Join a Store").find(:xpath, "..") do
      select "Account Three", from: "Select Store to Join"
      click_on "Join Store"
    end

    assert_text "You have successfully joined Account Three"

    # Verify we are still managing Account One and see both stores joined
    assert_text "Stores joined by Account One"
    within find("h2", text: "Stores joined by Account One").find(:xpath, "..") do
      assert_text "Account Two"
      assert_text "Account Three"
    end

    # Verify joined stores are NOT in the "Join a Store" list anymore
    # In fact, since no stores are left to join, the section should be gone
    assert_no_text "Join a Store"
  end
end
