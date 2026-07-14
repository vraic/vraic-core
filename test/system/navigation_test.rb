require "application_system_test_case"

class NavigationTest < ApplicationSystemTestCase
  setup do
    resize_to_desktop
    @manager = User.create!(name: "Store Manager", email_address: "manager@example.com", password: "Password123!@#Strong", password_confirmation: "Password123!@#Strong")
    @staff = User.create!(name: "Store Staff", email_address: "staff@example.com", password: "Password123!@#Strong", password_confirmation: "Password123!@#Strong")

    @account = Account.create!(name: "Managed Store", owner: @manager)
    AccountUser.create!(account: @account, user: @staff, user_role: :store_staff)
  end

  test "manager sees Store Settings in sidebar" do
    login_as(@manager)
    visit dashboard_path

    # Check desktop sidebar
    within "#desktop-sidebar-main-nav" do
      assert_text "Store Settings"
      click_on "Store Settings"
    end

    assert_current_path edit_account_path(@account)
    assert_text "Editing account"
    assert_text "Stores We Supply"
  end

  test "manager sees Store Settings in mobile sidebar" do
    resize_to_mobile
    login_as(@manager)
    visit dashboard_path

    find("button", text: "Open sidebar").click

    within "#mobile-sidebar-main-nav" do
      assert_text "Store Settings"
      click_on "Store Settings"
    end

    assert_current_path edit_account_path(@account)
  end

  test "manager with multiple stores can switch and see correct settings" do
    @account2 = Account.create!(name: "Second Store", owner: @manager)

    login_as(@manager)
    visit dashboard_path

    # On dashboard, click "Manage Store" for Second Store
    within "#stores-grid" do
      # Find the card for Second Store and click Manage Store there
      card = find("h3", text: "Second Store").ancestor(".overflow-hidden")
      within card do
        click_on "Manage Store"
      end
    end

    # Wait for the switch to happen
    assert_text "Dashboard"

    within "#desktop-sidebar-main-nav" do
      assert_text "Store Settings"
      click_on "Store Settings"
    end

    assert_current_path edit_account_path(@account2)
    assert_text "Editing account"
    assert_field "Name", with: "Second Store"
    assert_text "Stores We Supply"
  end

  test "staff does not see Store Settings in sidebar" do
    login_as(@staff)
    visit dashboard_path

    within "#desktop-sidebar-main-nav" do
      assert_no_text "Store Settings"
    end
  end
end
