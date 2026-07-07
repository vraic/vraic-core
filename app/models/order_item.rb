class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :inventory_item
  belongs_to :location, optional: true

  monetize :price_cents

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :sufficient_stock, if: :location_id

  before_validation :set_default_price, on: :create
  after_create :deduct_stock
  after_destroy :return_stock
  after_update :adjust_stock, if: :saved_change_to_quantity?

  def set_default_price
    if inventory_item && (price_cents.blank? || price_cents.zero?)
      self.price = inventory_item.price
    end
  end

  private

  def sufficient_stock
    return unless location_id && inventory_item

    current_stock = inventory_item.inventory_levels.find_by(location_id: location_id)&.quantity || 0
    # For existing records, we need to consider the quantity already allocated to this item
    available_stock = new_record? ? current_stock : current_stock + quantity_was

    if quantity > available_stock
      errors.add(:quantity, "cannot exceed available stock at this location (#{available_stock} #{inventory_item.stock_unit.pluralize(available_stock)})")
    end
  end

  def deduct_stock
    return unless location_id
    adjust_inventory_level(-quantity)
  end

  def return_stock
    return unless location_id && inventory_item.present?
    adjust_inventory_level(quantity)
  end

  def adjust_stock
    return unless location_id && inventory_item.present?
    diff = quantity - quantity_before_last_save
    adjust_inventory_level(-diff)
  end

  def adjust_inventory_level(amount)
    level = inventory_item.inventory_levels.find_or_initialize_by(location_id: location_id)
    level.quantity += amount
    level.save!
  end
end
