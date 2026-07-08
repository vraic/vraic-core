class AddExpiresAtToSupportRequests < ActiveRecord::Migration[8.1]
  def change
    add_column :support_requests, :expires_at, :datetime
  end
end
