class ReportPolicy < ApplicationPolicy
  def index?
    user.admin? || store_manager?
  end

  private

  def store_manager?
    tenant = ActsAsTenant.current_tenant || Current.account
    return false unless tenant
    user.account_users.exists?(account: tenant, user_role: :store_manager)
  end
end
