class Location < ApplicationRecord
  acts_as_tenant :account
  has_prefix_id :loc

  has_many :inventory_levels, dependent: :destroy
  has_many :inventory_items, through: :inventory_levels

  validates :name, presence: true
end
