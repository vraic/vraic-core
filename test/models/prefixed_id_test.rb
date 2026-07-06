require "test_helper"

class PrefixedIdTest < ActiveSupport::TestCase
  test "user has prefixed id" do
    user = users(:one)
    assert_match(/^user_/, user.to_param)
    assert_equal user, User.find_by_prefix_id(user.to_param)
  end

  test "account has prefixed id" do
    account = accounts(:one)
    assert_match(/^acct_/, account.to_param)
    assert_equal account, Account.find_by_prefix_id(account.to_param)
  end

  test "account_user has prefixed id" do
    account_user = account_users(:one)
    assert_match(/^au_/, account_user.to_param)
    assert_equal account_user, AccountUser.find_by_prefix_id(account_user.to_param)
  end
end
