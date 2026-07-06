class InventoryItem < ApplicationRecord
  acts_as_tenant :account
  acts_as_paranoid
  has_prefix_id :item

  belongs_to :inventory_group, optional: true
  belongs_to :parent, class_name: "InventoryItem", optional: true
  has_many :variants, class_name: "InventoryItem", foreign_key: "parent_id", dependent: :destroy
  has_many :inventory_levels, dependent: :destroy
  has_many :locations, through: :inventory_levels

  monetize :price_cents, allow_nil: true

  enum :unit_type, { per_unit: 0, per_weight: 1 }

  validates :name, presence: true
  validates :weight_value, presence: true, if: :per_weight?
  validates :weight_unit, presence: true, if: :per_weight?

  def display_name
    if parent
      "#{parent.name} - #{variant_label}"
    else
      name
    end
  end

  def variant_label
    if per_weight?
      "#{weight_value}#{weight_unit}"
    else
      name
    end
  end

  def price
    inherited_price = super
    return inherited_price if inherited_price.present? || parent.nil?

    parent.price
  end

  def total_quantity
    inventory_levels.sum(:quantity)
  end

  def stock_unit
    weight_unit.presence || "unit"
  end
end
