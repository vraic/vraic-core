class Account < ApplicationRecord
  has_prefix_id :acct
  has_many :account_users, dependent: :destroy
  has_many :users, through: :account_users
  has_one :owner, class_name: "AccountUser", foreign_key: "id"

  validates :name, presence: true
  validates :owner_id, presence: true
end
