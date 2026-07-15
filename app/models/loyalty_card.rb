class LoyaltyCard < ApplicationRecord
  audited associated_with: :loyalty_program
  has_prefix_id :lc

  belongs_to :customer
  belongs_to :loyalty_program
  has_many :loyalty_transactions, dependent: :destroy

  validates :identifier, presence: true, uniqueness: true
  validates :points_balance, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_validation :generate_identifier, on: :create

  def redeem_points!(points, order = nil, description = nil)
    raise "Insufficient points" if points_balance < points

    transaction do
      self.points_balance -= points
      save!
      loyalty_transactions.create!(
        amount: -points,
        transaction_type: :redemption,
        order: order,
        description: description || "Redemption for order #{order&.number}"
      )
    end
  end

  def add_points!(points, order = nil, description = nil)
    transaction do
      self.points_balance += points
      save!
      loyalty_transactions.create!(
        amount: points,
        transaction_type: :accrual,
        order: order,
        description: description || "Accrual from order #{order&.number}"
      )
    end
  end

  def total_points_earned
    loyalty_transactions.accrual.sum(:amount)
  end

  def total_points_redeemed
    loyalty_transactions.redemption.sum(:amount).abs
  end

  def lifetime_savings
    loyalty_program.points_to_currency(total_points_redeemed)
  end

  private

  def generate_identifier
    return if identifier.present?
    self.identifier = loop do
      code = SecureRandom.alphanumeric(10).upcase
      break code unless LoyaltyCard.exists?(identifier: code)
    end
  end
end
