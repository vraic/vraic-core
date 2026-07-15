class LoyaltyCardPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    record.customer.user_id == user.id || manager? || staff?
  end

  def create?
    # Must be a customer of the store to enroll
    Customer.where(account_id: Current.account.id, user_id: user.id).exists?
  end

  def wallet?
    show?
  end

  def offline?
    show?
  end

  class Scope < Scope
    def resolve
      if manager? || staff?
        scope.all
      else
        scope.joins(:customer).where(customers: { user_id: user.id })
      end
    end
  end
end
