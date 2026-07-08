require "test_helper"

class SupportRequestPolicyTest < ActiveSupport::TestCase
  setup do
    @admin = users(:administrator)
    @store_manager = users(:one)
    @account = accounts(:one)
    @support_request = support_requests(:one)
  end

  test "scope" do
    assert_includes Pundit.policy_scope!(@admin, SupportRequest), @support_request
    assert_includes Pundit.policy_scope!(@store_manager, SupportRequest), @support_request
  end

  test "show" do
    assert Pundit.policy!(@admin, @support_request).show?
    ActsAsTenant.with_tenant(@account) do
      assert Pundit.policy!(@store_manager, @support_request).show?
    end
  end

  test "create" do
    assert Pundit.policy!(@admin, SupportRequest.new).create?
    ActsAsTenant.with_tenant(@account) do
      assert Pundit.policy!(@store_manager, SupportRequest.new).create?
    end
  end

  test "update" do
    # Request from SM to platform
    request = SupportRequest.new(requester: @store_manager, account: @account, status: :pending)
    assert Pundit.policy!(@admin, request).update? # Admin accepts
    ActsAsTenant.with_tenant(@account) do
      assert_not Pundit.policy!(@store_manager, request).update? # SM can't accept own request
    end

    # Request from platform to SM
    request = SupportRequest.new(requester: @admin, account: @account, status: :pending)
    ActsAsTenant.with_tenant(@account) do
      assert Pundit.policy!(@store_manager, request).update? # SM accepts
    end
    assert_not Pundit.policy!(@admin, request).update? # Admin can't accept own request
  end
end
