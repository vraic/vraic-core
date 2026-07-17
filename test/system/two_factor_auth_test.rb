require "application_system_test_case"

class TwoFactorAuthTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    login_as @user
  end

  test "can setup and disable 2FA via OTP" do
    visit settings_path
    click_on "Setup Authenticator App"

    assert_text "Setup Two-Factor Authentication"
    assert_text "Manual Entry Token"

    # Get the secret from the page
    secret = find("code").text.strip
    totp = ROTP::TOTP.new(secret)

    fill_in "Enter verification code from app", with: totp.now
    click_on "Verify and Enable 2FA"

    assert_text "2FA has been enabled via OTP"
    assert_text "2FA is currently enabled via Authenticator App"

    # Now test login with OTP
    visit dashboard_path
    logout

    # We expect 2FA after signing in if enabled
    visit new_session_path
    fill_in "Email", with: @user.email_address
    click_button "Sign in with password"
    fill_in "Password", with: "password"
    click_button "Continue"

    assert_text "Two-Factor Verification"
    assert_text "Please enter the code from your authenticator app"

    assert_selector "input[name='otp_code']", wait: 10
    fill_in "Verification Code", with: totp.now
    click_button "Verify"

    assert_current_path dashboard_path, wait: 10
    assert_text "Séyiz les beinv'nus"
    assert_text @user.name

    # Disable 2FA
    visit settings_path
    click_on "Disable 2FA"
    assert_text "2FA has been disabled"
  end

  test "uses email fallback when OTP is not setup" do
    # 2FA is now forced in my implementation of login_as if we are on that page
    # But let's verify the email part

    visit dashboard_path
    logout

    visit new_session_path
    fill_in "Email", with: @user.email_address
    click_button "Sign in with password"
    fill_in "Password", with: "password"
    click_button "Continue"

    assert_text "Two-Factor Verification"
    assert_text "We've sent a verification code to your email address"

    # Use a robust way to get the token
    token = nil
    50.times do
      token = User.uncached { User.find(@user.id).email_otp_token }
      break if token.present?
      sleep 0.2
    end

    assert token.present?, "Expected email OTP token to be generated"

    assert_selector "input[name='otp_code']", wait: 10
    fill_in "Verification Code", with: token.to_s.strip.upcase
    click_button "Verify"

    assert_current_path dashboard_path, wait: 10
  end
end
