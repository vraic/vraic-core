class AccountUser < ApplicationRecord
  has_prefix_id :au
  acts_as_tenant :account
  belongs_to :user

  enum :user_role, { admin: 0, standard: 1, customer: 2 }
end
