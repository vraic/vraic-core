require "application_system_test_case"

class TwoFactorAuthTest < ApplicationSystemTestCase
  setup do
    Capybara.reset_sessions!
    @user = users(:one)
    @user.update!(security_choice_made: true, onboarded: true)
  end

  test "2FA setup: enabling authenticator app" do
    login_as(@user)
    visit settings_path

    click_on "Setup Authenticator App"
    assert_text "Setup Two-Factor Authentication"

    # Extract secret from the page
    secret = find("code#otp-secret").text.strip
    totp = ROTP::TOTP.new(secret)

    # Use deterministic time for code generation and verification.
    # This is a best practice to avoid flakiness in CI caused by TOTP window expiry.
    travel_to Time.current do
      fill_in "otp_code", with: totp.now
      click_on "Verify and Enable 2FA"
    end

    assert_text "2FA has been enabled via OTP"
    assert @user.reload.otp_enabled?

    # Cleanup: disable 2FA
    visit settings_path
    click_on "Disable 2FA"
    assert_text "2FA has been disabled"
    refute @user.reload.otp_enabled?
  end

  test "2FA login phase 1: entering credentials redirects to 2FA prompt" do
    @user.update!(otp_required_for_login: true)

    visit new_session_path
    fill_in "Email", with: @user.email_address
    click_button "Sign in with password"
    execute_script("document.querySelectorAll('[data-password-login-target=\"passwordFields\"]').forEach(el => el.classList.remove('hidden'))")
    fill_in "Password (optional)", with: "password"
    click_button "Continue"

    assert_current_path new_two_factor_verification_path, wait: 10
    assert_text "Two-Factor Verification"
  end

  test "2FA login phase 2: entering valid TOTP code completes login" do
    # Setup user with TOTP enabled
    @user.generate_otp_secret!
    secret = @user.otp_secret.strip
    totp = ROTP::TOTP.new(secret)
    @user.update!(otp_required_for_login: true)

    # Perform Phase 1 Login
    visit new_session_path
    fill_in "Email", with: @user.email_address
    click_button "Sign in with password"
    execute_script("document.querySelectorAll('[data-password-login-target=\"passwordFields\"]').forEach(el => el.classList.remove('hidden'))")
    fill_in "Password (optional)", with: "password"
    click_button "Continue"

    # Phase 2: Verification
    assert_text "Two-Factor Verification"
    assert_text "Please enter the code from your authenticator app"

    code = totp.now
    # Ensure the field is present and visible before interacting
    assert_selector "input#otp_code", visible: true
    sleep 0.5 # Small delay to ensure any initial JS settles

    # Use deterministic time for the submission
    travel_to Time.now do
      find_field("otp_code").set(code)
      assert_field "otp_code", with: code
      click_button "Verify"

      assert_text "Signed in successfully.", wait: 15
    end
    assert_current_path dashboard_path
  end

  test "2FA login phase 2: entering valid email OTP code completes login" do
    # Ensure 2FA is required but app is NOT setup
    @user.update!(otp_required_for_login: true, otp_secret: nil)

    # Perform Phase 1 Login
    visit new_session_path
    fill_in "Email", with: @user.email_address
    click_button "Sign in with password"
    execute_script("document.querySelectorAll('[data-password-login-target=\"passwordFields\"]').forEach(el => el.classList.remove('hidden'))")
    fill_in "Password (optional)", with: "password"
    click_button "Continue"

    # Phase 2: Verification
    assert_text "Two-Factor Verification"
    assert_text "We've sent a verification code to your email address"

    # Fetch token from DB - do this OUTSIDE travel_to to ensure we wait for real DB update
    token = nil
    50.times do
      token = User.uncached { @user.reload.email_otp_token }
      break if token.present?
      sleep 0.1
    end

    assert token.present?, "Email OTP token should have been generated"

    # Ensure the field is present and visible before interacting
    assert_selector "input#otp_code", visible: true
    sleep 0.5 # Small delay to ensure any initial JS settles

    # Use deterministic time for the submission
    travel_to Time.now do
      find_field("otp_code").set(token)
      assert_field "otp_code", with: token
      click_button "Verify"

      assert_text "Signed in successfully.", wait: 15
    end
    assert_current_path dashboard_path
  end
end
