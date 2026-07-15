require "test_helper"

class TwoFactorVerificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "new regenerates email otp when existing token is expired" do
    post session_path, params: { email_address: @user.email_address, password: "password" }
    assert_redirected_to new_two_factor_verification_path

    stale_token = User.find(@user.id).email_otp_token
    @user.update_columns(email_otp_sent_at: 16.minutes.ago)

    get new_two_factor_verification_path
    assert_response :success

    refreshed_token = User.find(@user.id).email_otp_token
    assert_not_equal stale_token, refreshed_token
  end
end