json.extract! inventory_item, :id, :name, :description, :price_cents, :price_currency, :account_id, :inventory_group_id, :parent_id, :unit_type, :weight_value, :weight_unit, :deleted_at, :created_at, :updated_at
json.url inventory_item_url(inventory_item, format: :json)
