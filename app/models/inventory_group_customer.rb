class InventoryGroupCustomer < ApplicationRecord
  belongs_to :inventory_group
  belongs_to :customer
end
