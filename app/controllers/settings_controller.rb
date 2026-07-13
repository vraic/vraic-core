class SettingsController < ApplicationController
  before_action :set_user

  def show
    @customer = Current.account.customers.find_by(user_id: @user.id)
    @supplier = Current.account.suppliers.find_by(user_id: @user.id)
  end

  def update
    @customer = Current.account.customers.find_by(user_id: @user.id)
    @supplier = Current.account.suppliers.find_by(user_id: @user.id)

    if @user.update(user_params)
      @customer&.update(subscribed_to_newsletter: params[:subscribed_to_newsletter_customer] == "1")
      @supplier&.update(subscribed_to_newsletter: params[:subscribed_to_newsletter_supplier] == "1")
      redirect_to settings_path, notice: "Personal information updated."
    else
      render :show, status: :unprocessable_content
    end
  end

  def update_password
    if @user.authenticate(params[:current_password])
      if @user.update(password_params)
        redirect_to settings_path, notice: "Password updated successfully."
      else
        render :show, status: :unprocessable_content
      end
    else
      @user.errors.add(:current_password, "is incorrect")
      render :show, status: :unprocessable_content
    end
  end

  def logout_sessions
    @user.sessions.where.not(id: Current.session.id).destroy_all
    redirect_to settings_path, notice: "Other sessions logged out."
  end

  def destroy
    @user.destroy!
    reset_session
    redirect_to root_path, notice: "Account deleted."
  end

  private

  def set_user
    @user = Current.user
  end

  def user_params
    params.require(:user).permit(:name, :email_address)
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
