class SupplierPrice < ApplicationRecord
  belongs_to :inventory_item
  belongs_to :supplier

  monetize :price_cents
end
