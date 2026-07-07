class AccountPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
    user.admin? || user.accounts.include?(record)
  end

  def create?
    user.present?
  end

  def update?
    user.admin? || account_admin?
  end

  def destroy?
    user.admin?
  end

  private

  def account_admin?
    user.account_users.find_by(account: record)&.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      else
        user.accounts
      end
    end
  end
end
