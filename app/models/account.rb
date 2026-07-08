class Account < ApplicationRecord
  audited
  has_associated_audits
  has_prefix_id :acct
  has_many :account_users
  has_many :customers
  has_many :suppliers
  has_many :sent_supplier_requests, class_name: "SupplierRequest", foreign_key: "sender_account_id", dependent: :destroy
  has_many :received_supplier_requests, class_name: "SupplierRequest", foreign_key: "receiver_account_id", dependent: :destroy
  has_many :users, through: :account_users
  has_many :notes, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :inventory_items, dependent: :destroy
  has_many :inventory_groups, dependent: :destroy
  has_many :locations, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :support_requests, dependent: :destroy
  belongs_to :owner, class_name: "User", foreign_key: "owner_id"

  validates :name, presence: true
  validates :owner_id, presence: true

  before_destroy :cleanup_side_effects

  private

  def cleanup_side_effects
    Customer.unscoped.where(account_id: id).delete_all!
    AccountUser.unscoped.where(account_id: id).delete_all
  end
end
