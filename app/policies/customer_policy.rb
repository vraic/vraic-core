class CustomerPolicy < ApplicationPolicy
  def index?
    staff?
  end

  def show?
    staff?
  end

  def create?
    staff?
  end

  def update?
    staff?
  end

  def destroy?
    staff?
  end

  def really_destroy?
    user.admin? || account_admin?
  end

  private

  def account_admin?
    user.account_users.find_by(account: Current.account)&.store_manager?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if staff?
        scope.all
      else
        scope.none
      end
    end
  end
end
