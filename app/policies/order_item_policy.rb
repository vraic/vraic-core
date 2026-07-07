class OrderItemPolicy < ApplicationPolicy
  def index?
    staff?
  end

  def show?
    staff? || record_belongs_to_customer?
  end

  def create?
    staff? || customer?
  end

  def update?
    staff?
  end

  def destroy?
    staff?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if staff?
        scope.all
      else
        user_account_ids = AccountUser.unscoped.where(user: user).pluck(:account_id)
        customer_ids = Customer.unscoped.where(account: Current.account)
                              .where("user_id = ? OR customer_account_id IN (?)", user.id, user_account_ids)
                              .pluck(:id)

        if customer_ids.any?
          scope.joins(:order).where(orders: { customer_id: customer_ids })
        else
          scope.none
        end
      end
    end
  end

  private

  def record_belongs_to_customer?
    # Personal customer record
    customer_record = Customer.find_by(user: user, account: Current.account)
    return true if customer_record && record.order.customer_id == customer_record.id

    # B2B customer record
    user_account_ids = AccountUser.unscoped.where(user: user).pluck(:account_id)
    b2b_customer_ids = Customer.unscoped.where(account: Current.account, customer_account_id: user_account_ids).pluck(:id)
    b2b_customer_ids.include?(record.order.customer_id)
  end
end
