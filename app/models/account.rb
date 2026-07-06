class Account < ApplicationRecord
  has_prefix_id :acct
  has_many :account_users
  has_many :customers
  has_many :users, through: :account_users
  has_one :owner, class_name: "AccountUser", foreign_key: "id"

  validates :name, presence: true
  validates :owner_id, presence: true

  before_destroy :cleanup_side_effects

  private

  def cleanup_side_effects
    Customer.unscoped.where(account_id: id).delete_all!
    AccountUser.unscoped.where(account_id: id).delete_all
  end
end
