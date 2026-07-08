class AddEmailOtpToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :email_otp_token, :string
    add_column :users, :email_otp_sent_at, :datetime
  end
end
