json.extract! user, :id, :email_address, :user_type, :admin, :created_at, :updated_at
json.url user_url(user, format: :json)
