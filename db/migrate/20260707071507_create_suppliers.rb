class CreateSuppliers < ActiveRecord::Migration[8.1]
  def change
    create_table :suppliers do |t|
      t.string :name
      t.string :email_address
      t.string :phone
      t.references :account, null: false, foreign_key: true
      t.references :supplier_account, null: true, foreign_key: { to_table: :accounts }
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :suppliers, :deleted_at
  end
end
