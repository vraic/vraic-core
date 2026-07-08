class SupplierPolicy < ApplicationPolicy
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

  def inventory?
    staff? && record.supplier_account_id.present?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        authorized_scope
      elsif staff?
        scope.all
      else
        scope.none
      end
    end
  end
end
