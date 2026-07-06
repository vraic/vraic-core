class CreateAccountUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :account_users do |t|
      t.integer :account_id
      t.integer :user_id
      t.integer :user_role, default: 0

      t.timestamps
    end
  end
end
