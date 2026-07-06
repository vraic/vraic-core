class AccountUser < ApplicationRecord
  belongs_to :account
  belongs_to :user

  enum :user_role, { admin: 0, standard: 1 }
end
