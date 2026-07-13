class AddSecurityPreferencesToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :prefers_email_login, :boolean, default: false, null: false
    add_column :users, :security_choice_made, :boolean, default: false, null: false
  end
end
