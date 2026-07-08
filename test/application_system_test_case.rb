require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  setup do
    Capybara.default_max_wait_time = 10
  end

  def login_as(user)
    visit new_session_url
    fill_in "Email", with: user.email_address
    fill_in "Password", with: "password"
    click_button "Sign in"

    # We expect 2FA after signing in. Wait for it to appear.
    if page.has_text?("Two-Factor Verification", wait: 10)
      code = if user.otp_enabled?
        ROTP::TOTP.new(user.otp_secret).now
      else
        # Email token is generated on the 'new' action of TwoFactorVerificationsController
        # We reload until it's present to avoid race conditions
        token = nil
        10.times do
          token = user.reload.email_otp_token
          break if token.present?
          sleep 0.1
        end
        token
      end
      fill_in "Verification Code", with: code
      click_button "Verify"
    end

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
