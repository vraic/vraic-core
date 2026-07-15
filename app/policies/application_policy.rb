# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def staff?
    return true if user.admin?
    tenant = ActsAsTenant.current_tenant || Current.account
    return false unless tenant
    user.account_users.exists?(account: tenant, user_role: [ :store_manager, :store_staff ])
  end

  def manager?
    return true if user.admin?
    tenant = ActsAsTenant.current_tenant || Current.account
    return false unless tenant
    user.account_users.exists?(account: tenant, user_role: :store_manager)
  end

  def customer?
    tenant = ActsAsTenant.current_tenant || Current.account
    return false unless tenant
    user.account_users.exists?(account: tenant, user_role: :customer)
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NoMethodError, "You must define #resolve in #{self.class}"
    end

    def staff?
      return true if user.admin?
      tenant = ActsAsTenant.current_tenant || Current.account
      return false unless tenant
      user.account_users.exists?(account: tenant, user_role: [ :store_manager, :store_staff ])
    end

    def manager?
      return true if user.admin?
      tenant = ActsAsTenant.current_tenant || Current.account
      return false unless tenant
      user.account_users.exists?(account: tenant, user_role: :store_manager)
    end

    def customer?
      tenant = ActsAsTenant.current_tenant || Current.account
      return false unless tenant
      user.account_users.exists?(account: tenant, user_role: :customer)
    end

    def authorized_scope
      if user.admin?
        if ActsAsTenant.current_tenant
          scope.all
        else
          # Global view: only show data from accounts with active support requests
          authorized_account_ids = SupportRequest.active.pluck(:account_id)
          scope.where(account_id: authorized_account_ids)
        end
      else
        scope.where(account_id: user.account_users.pluck(:account_id))
      end
    end

    private

    attr_reader :user, :scope
  end
end
