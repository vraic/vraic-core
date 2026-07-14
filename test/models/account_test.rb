require "test_helper"

class AccountTest < ActiveSupport::TestCase
  test "creating an account while another tenant is active does not cause RecordNotUnique for the owner" do
    user = users(:one)
    other_account = accounts(:one)

    # Ensure user is already in another account (as they are in fixtures)
    assert user.account_users.exists?(account: other_account)

    ActsAsTenant.with_tenant(other_account) do
      new_account = Account.new(name: "New Store", owner: user)
      assert_nothing_raised do
        new_account.save!
      end

      # Verify the user is now also a store_manager of the new account
      assert AccountUser.unscoped.exists?(account: new_account, user: user, user_role: "store_manager")
    end
  end
end
