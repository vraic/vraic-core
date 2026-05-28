require "application_system_test_case"

class SessionsTest < ApplicationSystemTestCase
  test "visiting new sessions / login page" do
    visit new_sessions_url

    assert_selector "h1", text: "Sign in to your account"
  end
end
