class SupplierRequestPolicy < ApplicationPolicy
  def index?
    true
  end

  def create?
    # Must be global admin OR admin of the sender account
    return true if user.admin?

    sender = record.respond_to?(:sender_account) ? record.sender_account : nil
    sender ||= ActsAsTenant.current_tenant

    return false unless sender

    AccountUser.unscoped.exists?(user: user, account: sender, user_role: :store_manager)
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
      # Show all requests for admins in global view
      if user.admin? && ActsAsTenant.current_tenant.nil?
        return scope.all
      end

      # Show requests sent or received by the current account
      tenant = ActsAsTenant.current_tenant
      scope.where(sender_account: tenant).or(scope.where(receiver_account: tenant))
    end
  end
end
