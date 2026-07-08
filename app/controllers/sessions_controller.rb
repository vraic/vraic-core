class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create test_login ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }

  layout "sessions"

  def new
  end

  def test_login
    if Rails.env.test?
      user = User.find(params[:user_id])
      start_new_session_for user
      redirect_to dashboard_path, notice: "Logged in as #{user.email_address}"
    else
      head :forbidden
    end
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      session[:otp_user_id] = user.id
      redirect_to new_two_factor_verification_path
    else
      redirect_to new_session_path, alert: "Try another email address or password."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end
end
