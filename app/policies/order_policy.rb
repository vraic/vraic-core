class OrderPolicy < ApplicationPolicy
  def index?
    admin_or_staff? || customer?
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
      if user.admin?
        authorized_scope
      elsif staff?
        scope.all
      else
        user_account_ids = AccountUser.unscoped.where(user: user, user_role: [ :store_manager, :store_staff ]).pluck(:account_id)
        customer_ids = Customer.unscoped.where(account: Current.account)
                              .where("user_id = ? OR customer_account_id IN (?)", user.id, user_account_ids)
                              .pluck(:id)

        if customer_ids.any?
          scope.where(customer_id: customer_ids)
        else
          scope.none
        end
      end
    end
  end

  private

  def admin_or_staff?
    user.admin? || user.account_users.exists?(account: Current.account, user_role: [ :store_manager, :store_staff ])
  end

  def customer?
    user.account_users.exists?(account: Current.account, user_role: :customer)
  end

  def record_belongs_to_customer?
    # Personal customer record
    customer_record = Customer.find_by(user: user, account: Current.account)
    return true if customer_record && record.customer_id == customer_record.id

    # B2B customer record
    user_account_ids = AccountUser.unscoped.where(user: user, user_role: [ :store_manager, :store_staff ]).pluck(:account_id)
    b2b_customer_ids = Customer.unscoped.where(account: Current.account, customer_account_id: user_account_ids).pluck(:id)
    b2b_customer_ids.include?(record.customer_id)
  end
end
