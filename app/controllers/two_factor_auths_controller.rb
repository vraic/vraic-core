class TwoFactorAuthsController < ApplicationController
  def show
    @user = Current.user
    @user.generate_otp_secret! if @user.otp_secret.blank?
    @qr_code = @user.otp_qr_code
  end

  def create
    if Current.user.validate_otp(params[:otp_code])
      Current.user.update!(otp_required_for_login: true)
      redirect_to settings_path, notice: "2FA has been enabled via OTP."
    else
      redirect_to two_factor_auth_path, alert: "Invalid OTP code. Please try again."
    end
  end

  def destroy
    Current.user.update!(otp_required_for_login: false, otp_secret: nil)
    redirect_to settings_path, notice: "2FA has been disabled."
  end
end
