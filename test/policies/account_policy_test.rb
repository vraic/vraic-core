require "test_helper"

class AccountPolicyTest < ActiveSupport::TestCase
  setup do
    @admin = users(:administrator)
    @user_one = users(:one) # Admin of account one
    @user_two = users(:two) # Standard of account two
    @account_one = accounts(:one)
    @account_two = accounts(:two)
  end

  def test_scope
    # Global admin sees all
    scope = AccountPolicy::Scope.new(@admin, Account).resolve
    assert_includes scope, @account_one
    assert_includes scope, @account_two

    # Regular user sees only their accounts
    scope = AccountPolicy::Scope.new(@user_one, Account).resolve
    assert_includes scope, @account_one
    assert_not_includes scope, @account_two
  end

  def test_show
    assert AccountPolicy.new(@admin, @account_one).show?
    assert AccountPolicy.new(@user_one, @account_one).show?
    assert_not AccountPolicy.new(@user_one, @account_two).show?
  end

  def test_create
    assert AccountPolicy.new(@admin, Account).create?
    assert_not AccountPolicy.new(@user_one, Account).create?
  end

  def test_update
    assert AccountPolicy.new(@admin, @account_one).update?
    assert AccountPolicy.new(@user_one, @account_one).update? # user_one is admin of account_one
    assert_not AccountPolicy.new(@user_two, @account_two).update? # user_two is standard of account_two
    assert_not AccountPolicy.new(@user_one, @account_two).update?
  end

  def test_destroy
    assert AccountPolicy.new(@admin, @account_one).destroy?
    assert_not AccountPolicy.new(@user_one, @account_one).destroy?
  end
end
