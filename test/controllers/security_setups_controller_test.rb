require "test_helper"

class SecuritySetupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as(@user)
  end

  test "show" do
    get security_setup_path

    assert_response :success
    assert_select "h1", text: "How would you like to sign in?"
  end

  test "choosing email login updates preference" do
    post security_setup_path, params: { choice: "email_login" }

    assert_redirected_to dashboard_path
    @user.reload
    assert @user.prefers_email_login?
    assert @user.security_choice_made?
  end

  test "choosing password redirects to secure password setup" do
    post security_setup_path, params: { choice: "password" }

    assert_redirected_to password_security_setup_path
  end

  test "password setup redirects to two factor recommendation" do
    patch update_password_security_setup_path, params: {
      user: { password: "Th!sIsVeryStrong@P4ssw0rd", password_confirmation: "Th!sIsVeryStrong@P4ssw0rd" }
    }

    assert_redirected_to two_factor_security_setup_path
    @user.reload
    assert_not @user.prefers_email_login?
    assert @user.security_choice_made?
  end

  test "password setup rejects weak passwords" do
    patch update_password_security_setup_path, params: {
      user: { password: "password", password_confirmation: "password" }
    }

    assert_response :unprocessable_content
    assert_select "p", /too weak/
  end
end
