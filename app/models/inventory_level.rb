class InventoryLevel < ApplicationRecord
  acts_as_tenant :account
  has_prefix_id :lvl

  belongs_to :inventory_item
  belongs_to :location

  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :location_id, uniqueness: { scope: :inventory_item_id, message: "already has a level for this item" }
end
