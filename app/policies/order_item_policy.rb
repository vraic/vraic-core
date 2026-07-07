class OrderItemPolicy < ApplicationPolicy
  def index?
    admin_or_staff?
  end

  def show?
    admin_or_staff? || record_belongs_to_customer?
  end

  def create?
    admin_or_staff? || customer?
  end

  def update?
    admin_or_staff?
  end

  def destroy?
    admin_or_staff?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if admin_or_staff?
        scope.all
      else
        customer_record = Customer.find_by(user: user, account: Current.account)
        if customer_record
          scope.joins(:order).where(orders: { customer_id: customer_record.id })
        else
          scope.none
        end
      end
    end

    private

    def admin_or_staff?
      user.admin? || user.account_users.exists?(account: Current.account, user_role: [ :admin, :standard ])
    end
  end

  private

  def admin_or_staff?
    user.admin? || user.account_users.exists?(account: Current.account, user_role: [ :admin, :standard ])
  end

  def customer?
    user.account_users.exists?(account: Current.account, user_role: :customer)
  end

  def record_belongs_to_customer?
    customer_record = Customer.find_by(user: user, account: Current.account)
    customer_record && record.order.customer_id == customer_record.id
  end
end
