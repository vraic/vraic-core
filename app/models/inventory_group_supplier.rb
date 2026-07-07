class InventoryGroupSupplier < ApplicationRecord
  belongs_to :inventory_group
  belongs_to :supplier
end
