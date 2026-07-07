require "test_helper"

class NavigationVisibilityTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:administrator)
    @staff = users(:one)
    @customer = users(:three)
  end

  test "global admin sees all links" do
    sign_in_as(@admin)
    get dashboard_path
    assert_select "nav" do
      assert_select "a", text: /Tasks/
      assert_select "a", text: /Customers/
      assert_select "a", text: /Inventory/
      assert_select "a", text: /Orders/
      assert_select "a", text: /Settings/
    end
  end

  test "staff user sees all links" do
    sign_in_as(@staff)
    get dashboard_path
    assert_select "nav" do
      assert_select "a", text: /Tasks/
      assert_select "a", text: /Customers/
      assert_select "a", text: /Inventory/
      assert_select "a", text: /Orders/
      assert_select "a", text: /Settings/
    end
  end

  test "customer user sees only limited links" do
    sign_in_as(@customer)
    get dashboard_path
    assert_select "nav" do
      assert_select "a", text: /Dashboard/
      assert_select "a", text: /Orders/
      assert_select "a", text: /Tasks/, count: 0
      assert_select "a", text: /Customers/, count: 0
      assert_select "a", text: /Inventory/, count: 0
      assert_select "a", text: /Reports/, count: 0
    end
    # Settings should also be hidden for customers
    assert_select "nav a", text: /Settings/, count: 0
  end
end
