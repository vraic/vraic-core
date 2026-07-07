class SupplierRequestPolicy < ApplicationPolicy
  def index?
    true
  end

  def create?
    true
  end

  def update?
    # Only the receiver can approve/reject the request
    record.receiver_account_id == ActsAsTenant.current_tenant&.id
  end

  def destroy?
    # Sender can cancel, receiver can reject (delete)
    record.sender_account_id == ActsAsTenant.current_tenant&.id || record.receiver_account_id == ActsAsTenant.current_tenant&.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      # Show requests sent or received by the current account
      tenant = ActsAsTenant.current_tenant
      scope.where(sender_account: tenant).or(scope.where(receiver_account: tenant))
    end
  end
end
