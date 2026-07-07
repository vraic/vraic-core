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

    def customer?
      tenant = ActsAsTenant.current_tenant || Current.account
      return false unless tenant
      user.account_users.exists?(account: tenant, user_role: :customer)
    end

    private

    attr_reader :user, :scope
  end
end
