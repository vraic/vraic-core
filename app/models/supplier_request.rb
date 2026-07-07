class SupplierRequest < ApplicationRecord
  belongs_to :sender_account, class_name: "Account"
  belongs_to :receiver_account, class_name: "Account"

  enum :status, { pending: 0, approved: 1, rejected: 2 }

  validates :sender_account_id, uniqueness: { scope: :receiver_account_id, message: "has already sent a request to this account" }

  after_update :create_relationships, if: -> { saved_change_to_status? && approved? }

  private

  def create_relationships
    # Receiver account becomes a Customer of the Sender account
    sender_account.customers.create!(
      name: receiver_account.name,
      customer_account: receiver_account
    )

    # Sender account becomes a Supplier of the Receiver account
    receiver_account.suppliers.create!(
      name: sender_account.name,
      supplier_account: sender_account
    )
  end
end
