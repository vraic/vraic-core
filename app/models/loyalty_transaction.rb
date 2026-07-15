class LoyaltyTransaction < ApplicationRecord
  belongs_to :loyalty_card
  belongs_to :order, optional: true

  enum :transaction_type, { accrual: 0, redemption: 1 }

  validates :amount, presence: true, numericality: { other_than: 0 }
  validates :transaction_type, presence: true
end
