class SupportRequestPolicy < ApplicationPolicy
  def index?
    user.admin? || staff?
  end

  def show?
    user.admin? || (staff? && record.account_id == user.account_users.find_by(account_id: record.account_id)&.account_id)
  end

  def create?
    # Admins can create requests for any account
    # Staff can create for their current account
    user.admin? || staff?
  end

  def update?
    # Both parties can close an active or extension-requested ticket
    if record.accepted? || record.extension_requested?
      return true if user.admin? || account_admin?
    end

    if record.requester.admin?
      return account_admin? if record.pending? # SM accepts admin's request
    else
      return user.admin? if record.pending? # Admin accepts SM's request
    end

    false
  end

  def extend?
    # Only admins can request extensions on active tickets
    user.admin? && record.active?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(account_id: user.account_users.pluck(:account_id))
      end
    end
  end

  private

  def account_admin?
    user.account_users.find_by(account: record.account)&.store_manager?
  end
end
