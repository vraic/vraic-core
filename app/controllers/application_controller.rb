class ApplicationController < ActionController::Base
  include Authentication
  include Authorization
  include Pagy::Method

  set_current_tenant_through_filter
  before_action :set_tenant

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  def find_current_auditor
    Current.user if Current.user&.admin?
  end

  def require_account!
    return if Current.user&.admin? # Admins can have nil account (Global view)

    if Current.account.nil?
      redirect_to dashboard_path, alert: "Please select a store to continue."
    end
  end

  private

    def set_tenant
      return unless authenticated?

      account_id = session[:managed_account_id]

      if Current.user.admin?
        account = Account.find_by(id: account_id) if account_id
        set_current_tenant(account)
      else
        # For non-admins, they must belong to the account
        if account_id && AccountUser.unscoped.where(user_id: Current.user.id, account_id: account_id).exists?
          account = Account.find(account_id)
          set_current_tenant(account)
        elsif ActsAsTenant.without_tenant { Current.user.accounts.count } == 1
          # Fallback only if they have exactly one account
          account = ActsAsTenant.without_tenant { Current.user.accounts.first }
          set_current_tenant(account)
        else
          # Multiple accounts or none - require selection
          set_current_tenant(nil)
        end
      end

      Current.account = ActsAsTenant.current_tenant
    end
end
