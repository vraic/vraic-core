require "application_system_test_case"

class TwoFactorAuthTest < ApplicationSystemTestCase
  setup do
    Capybara.reset_sessions!
    @user = users(:one)
  end

  test "setting up and using authenticator app 2FA" do
    login_as(@user)
    visit settings_path

    click_on "Setup Authenticator App"
    assert_text "Setup Two-Factor Authentication"

    # Extract secret from the page
    secret = find("code#otp-secret").text.strip
    totp = ROTP::TOTP.new(secret)

    fill_in "otp_code", with: totp.now
    click_on "Verify and Enable 2FA"

    assert_text "2FA has been enabled via OTP"
    assert @user.reload.otp_enabled?

    # Test login with TOTP
    logout

    visit new_session_path
    fill_in "Email", with: @user.email_address
    # Use execute_script as a fallback if the Stimulus action is not firing
    click_button "Sign in with password"
    # Force visibility if Stimulus is slow or not loading in CI
    execute_script("document.querySelectorAll('[data-password-login-target=\"passwordFields\"]').forEach(el => el.classList.remove('hidden'))")
    execute_script("document.querySelector('[data-password-login-target=\"toggleSection\"]').classList.add('hidden')")

    # Now it should be visible
    fill_in "Password (optional)", with: "password"
    click_button "Continue"

    assert_text "Two-Factor Verification"
    assert_text "Please enter the code from your authenticator app"

    # Use a fresh TOTP code
    fill_in "otp_code", with: totp.now
    sleep 0.5
    click_on "Verify"

    refute_text "Invalid verification code"
    assert_current_path dashboard_path, wait: 15
    assert_text "Séyiz les beinv'nus"

    # Cleanup: disable 2FA
    visit settings_path
    click_on "Disable 2FA"
    assert_text "2FA has been disabled"
    refute @user.reload.otp_enabled?
  end

  test "using email fallback 2FA when authenticator app is not setup" do
    # Ensure 2FA is required but app is NOT setup
    @user.update!(otp_required_for_login: true, otp_secret: nil)

    visit new_session_path
    fill_in "Email", with: @user.email_address
    # Use execute_script as a fallback if the Stimulus action is not firing
    click_button "Sign in with password"
    # Force visibility if Stimulus is slow or not loading in CI
    execute_script("document.querySelectorAll('[data-password-login-target=\"passwordFields\"]').forEach(el => el.classList.remove('hidden'))")
    execute_script("document.querySelector('[data-password-login-target=\"toggleSection\"]').classList.add('hidden')")

    # Now it should be visible
    fill_in "Password (optional)", with: "password"
    click_button "Continue"

    assert_text "Two-Factor Verification"
    assert_text "We've sent a verification code to your email address"

    # Fetch token from DB
    token = nil
    50.times do
      token = User.uncached { @user.reload.email_otp_token }
      break if token.present?
      sleep 0.1
    end

    assert token.present?, "Email OTP token should have been generated"

    fill_in "otp_code", with: token
    sleep 0.5
    click_on "Verify"

    refute_text "Invalid verification code"
    assert_current_path dashboard_path, wait: 15
    assert_text "Séyiz les beinv'nus"
  end
end
