json.extract! supplier, :id, :name, :email_address, :phone, :account_id, :deleted_at, :created_at, :updated_at
json.url supplier_url(supplier, format: :json)
