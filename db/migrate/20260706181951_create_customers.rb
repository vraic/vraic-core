class CreateCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :customers do |t|
      t.string :name
      t.string :email_address
      t.string :phone
      t.references :account, null: false, foreign_key: true
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :customers, :deleted_at
  end
end
