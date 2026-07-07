class Location < ApplicationRecord
  acts_as_tenant :account
  has_prefix_id :loc

  has_many :inventory_levels, dependent: :destroy
  has_many :inventory_items, through: :inventory_levels
  has_many :order_items, dependent: :nullify

  validates :name, presence: true

  scope :collection_points, -> { where(collection_point: true) }
end
