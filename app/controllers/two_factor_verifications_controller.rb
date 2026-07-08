class TwoFactorVerificationsController < ApplicationController
  allow_unauthenticated_access
  layout "sessions"

  before_action :set_user

  def new
    if !@user.otp_enabled?
      @user.generate_email_otp! if @user.email_otp_token.blank? || @user.email_otp_sent_at < 1.minute.ago
    end
  end

  def create
    if verify_otp
      @user.clear_email_otp!
      start_new_session_for @user
      session.delete(:otp_user_id)
      redirect_to after_authentication_url
    else
      flash.now[:alert] = "Invalid verification code."
      render :new, status: :unprocessable_content
    end
  end

  private

  def set_user
    @user = User.find_by(id: session[:otp_user_id])
    redirect_to new_session_path if @user.nil?
  end

  def verify_otp
    if @user.otp_enabled?
      @user.validate_otp(params[:otp_code])
    else
      @user.validate_email_otp(params[:otp_code])
    end
  end
end
