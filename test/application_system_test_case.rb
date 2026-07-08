require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  setup do
    Capybara.default_max_wait_time = 10
  end

  def login_as(user)
    # Clear any existing OTP tokens to ensure we get a fresh one generated for this session
    user.update_columns(email_otp_token: nil, email_otp_sent_at: nil)

    Capybara.reset_sessions!
    visit new_session_url
    fill_in "Email", with: user.email_address
    fill_in "Password", with: "password"
    click_button "Sign in"

    # We expect 2FA after signing in.
    assert_selector "h2", text: "Two-Factor Verification", wait: 15

    code = if user.otp_enabled?
      ROTP::TOTP.new(user.otp_secret).now
    else
      # Wait for token with explicit reload and retry
      token = nil
      50.times do
        # Use uncached find to get the absolute latest from the DB
        u = User.uncached { User.find(user.id) }
        token = u.email_otp_token
        break if token.present?
        sleep 0.2
      end
      raise "Email OTP token not found for user #{user.email_address}" if token.blank?
      token
    end

    fill_in "Verification Code", with: code
    # Ensure the code was actually filled
    assert_field "Verification Code", with: code

    # Small delay before clicking to avoid race conditions with Turbo/JS
    sleep 0.2
    click_on "Verify"

    # Wait for the transition to complete
    assert_no_text "Two-Factor Verification", wait: 15
    assert_text "Dashboard", wait: 5
    assert_current_path dashboard_path
  end

  def select_account(name)
    # Use the Accounts page for admins to Join
    if page.has_link?("Administration")
      visit accounts_path
      row = find("tr", text: name)
      if row.has_button?("Join Account")
        within row do
          click_on "Join Account"
        end
        # Joining redirects to dashboard
      elsif row.has_button?("Leave Account")
        # Already joined
        visit dashboard_path
      end
    else
      visit dashboard_path
      # Find the account section and click Select
      # Use a more specific selector to avoid ambiguous matches
      # Search in both your-stores and business-stores
      selected = false
      [ "#your-stores", "#business-stores" ].each do |section|
        next unless page.has_css?(section)
        within section do
          if page.has_text?(name)
            within find("h3", text: name).find(:xpath, "../..") do
              if page.has_text?("Active")
                selected = true
                break
              elsif page.has_button?("Select")
                click_on "Select"
                selected = true
                break
              end
            end
          end
        end
        break if selected
      end
    end

    assert_text name
    # Verify banner if it's an admin
    if page.has_link?("Administration")
      assert_selector "div", text: "Managing Account: #{name}"
    end
  end

  def logout
    # There are multiple Logout buttons (mobile and desktop)
    # Use first to avoid ambiguous match
    first(:button, "Logout").click
  end

  def grant_support_access(account, user = nil)
    user ||= users(:administrator)
    SupportRequest.create!(
      account: account,
      requester: user,
      status: :accepted,
      expires_at: 72.hours.from_now,
      message: "Test authorization"
    )
  end
end
