class AccountUserPolicy < ApplicationPolicy
  def index?
    user.admin? || account_manager?
  end

  def show?
    user.admin? || account_manager? || record.user == user
  end

  def create?
    user.admin? || account_manager?
  end

  def update?
    user.admin? || account_manager?
  end

  def destroy?
    # Cannot remove yourself if you are a manager?
    # Actually, owners might need to stay, but the requirement doesn't specify.
    # For now, let's allow managers to manage others.
    user.admin? || account_manager?
  end

  private

  def account_manager?
    # Use the account from the record if it's an AccountUser
    # Or Current.account if we are in a tenant context
    account = record.is_a?(AccountUser) ? record.account : Current.account
    return false unless account

    AccountUser.unscoped.find_by(user: user, account: account)&.store_manager?
  end
end
