class AccountUser < ApplicationRecord
  acts_as_tenant :account
  belongs_to :user

  enum :user_role, { admin: 0, standard: 1 }
end
