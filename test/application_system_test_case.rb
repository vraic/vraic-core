require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  setup do
    Capybara.default_max_wait_time = 10
  end

  def login_as(user)
    Capybara.reset_sessions!
    visit new_session_url
    fill_in "Email", with: user.email_address
    fill_in "Password", with: "password"
    click_button "Sign in"

    # We expect 2FA after signing in.
    assert_selector "h2", text: "Two-Factor Verification", wait: 10

    code = if user.otp_enabled?
      ROTP::TOTP.new(user.otp_secret).now
    else
      # Email token is generated on the 'new' action of TwoFactorVerificationsController
      # We reload until it's present to avoid race conditions
      token = nil
      50.times do
        token = user.reload.email_otp_token
        break if token.present?
        sleep 0.1
      end
      raise "Email OTP token not found for user #{user.email_address}" if token.blank?
      token
    end
    fill_in "Verification Code", with: code
    click_button "Verify"

    assert_text "Dashboard"
    assert_current_path dashboard_path
  end

  def select_account(name)
    visit dashboard_path
    within "form[action='#{managed_account_path}']" do
      select name, from: "account_id"
      click_on "Go"
    end
    assert_text "Now managing #{name}"
  end
end
