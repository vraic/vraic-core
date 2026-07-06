class InventoryGroup < ApplicationRecord
  acts_as_tenant :account
  has_prefix_id :igrp

  has_many :inventory_items, dependent: :nullify

  validates :name, presence: true
end
