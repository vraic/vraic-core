json.extract! order, :id, :number, :account_id, :customer_id, :status, :total_amount_cents, :currency, :notes, :user_id, :created_at, :updated_at
json.url order_url(order, format: :json)
