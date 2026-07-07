json.extract! order_item, :id, :order_id, :inventory_item_id, :quantity, :price_cents, :currency, :created_at, :updated_at
json.url order_item_url(order_item, format: :json)
