json.extract! customer, :id, :name, :email_address, :phone, :account_id, :deleted_at, :created_at, :updated_at
json.url customer_url(customer, format: :json)
