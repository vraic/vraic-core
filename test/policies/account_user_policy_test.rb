require "test_helper"

class AccountUserPolicyTest < ActiveSupport::TestCase
  def setup
    @admin = users(:administrator)
    @manager = users(:one)
    @staff = users(:two)
    @other_user = users(:three)
    @account = accounts(:one)

    # Fixture one belongs to account one as manager
    # Fixture two belongs to account two as staff
    # Fixture three belongs to account one as customer

    @account_user = account_users(:one) # manager on account one
  end

  test "admin can do anything" do
    policy = AccountUserPolicy.new(@admin, @account_user)
    assert policy.index?
    assert policy.show?
    assert policy.create?
    assert policy.update?
    assert policy.destroy?
  end

  test "manager can manage users for their account" do
    ActsAsTenant.with_tenant(@account) do
      policy = AccountUserPolicy.new(@manager, @account_user)
      assert policy.index?
      assert policy.show?
      assert policy.create?
      assert policy.update?
      assert policy.destroy?
    end
  end

  test "staff cannot manage users" do
    ActsAsTenant.with_tenant(@account) do
      policy = AccountUserPolicy.new(@staff, @account_user)
      refute policy.index?
      refute policy.create?
      refute policy.update?
      refute policy.destroy?
    end
  end

  test "user can show their own record" do
    ActsAsTenant.with_tenant(@account) do
      policy = AccountUserPolicy.new(@other_user, account_users(:three))
      assert policy.show?
    end
  end
end
