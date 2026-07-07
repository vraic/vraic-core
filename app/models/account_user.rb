class AccountUser < ApplicationRecord
  has_prefix_id :au
  acts_as_tenant :account
  belongs_to :user

  enum :user_role, { store_manager: 0, store_staff: 1, customer: 2 }
end
