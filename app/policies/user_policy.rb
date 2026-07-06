class UserPolicy < ApplicationPolicy
  def index?
    user.admin? || account_admin?
  end

  def show?
    user.admin? || same_account?
  end

  def create?
    user.admin? || account_admin?
  end

  def update?
    user.admin? || user == record || account_admin?
  end

  def destroy?
    user.admin? || account_admin?
  end

  private

  def account_admin?
    tenant = ActsAsTenant.current_tenant
    return false unless tenant

    user.account_users.find_by(account: tenant)&.admin?
  end

  def same_account?
    tenant = ActsAsTenant.current_tenant
    return false unless tenant

    record.accounts.include?(tenant)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      else
        tenant = ActsAsTenant.current_tenant
        if tenant
          scope.joins(:account_users).where(account_users: { account_id: tenant.id })
        else
          scope.none
        end
      end
    end
  end
end
