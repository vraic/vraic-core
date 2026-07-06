json.extract! inventory_level, :id, :inventory_item_id, :location_id, :quantity, :account_id, :created_at, :updated_at
json.url inventory_level_url(inventory_level, format: :json)
