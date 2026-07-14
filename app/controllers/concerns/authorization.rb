module Authorization
  extend ActiveSupport::Concern
  include Pundit::Authorization

  included do
    # Uncomment to enforce Pundit authorization for every controller.
    # Add `skip_after_action :verify_authorized` for public controllers.

    # after_action :verify_authorized
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    helper_method :staff?, :customer?, :manager?
  end

  def pundit_user
    Current.user
  end

  def staff?
    Current.user&.admin? || Current.user&.account_users&.exists?(account: Current.account, user_role: [ :store_manager, :store_staff ])
  end

  def manager?
    return false unless Current.account
    Current.user&.admin? || Current.user&.account_users&.exists?(account: Current.account, user_role: :store_manager)
  end

  def customer?
    Current.user&.account_users&.exists?(account: Current.account, user_role: :customer)
  end

  private

  # You can also customize the messages using the policy and action to generate the I18n key
  # https://github.com/varvet/pundit#creating-custom-error-messages
  def user_not_authorized
    redirect_back_or_to root_path, alert: t("unauthorized")
  end
end
