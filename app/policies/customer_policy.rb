class CustomerPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    true
  end

  def update?
    true
  end

  def destroy?
    true
  end

  def really_destroy?
    user.admin? || account_admin?
  end

  private

  def account_admin?
    # ActsAsTenant.current_tenant should be set by the controller before this is called
    tenant = ActsAsTenant.current_tenant
    return false unless tenant

    user.account_users.find_by(account: tenant)&.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
