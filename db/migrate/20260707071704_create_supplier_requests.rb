class CreateSupplierRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :supplier_requests do |t|
      t.references :sender_account, null: false, foreign_key: { to_table: :accounts }
      t.references :receiver_account, null: false, foreign_key: { to_table: :accounts }
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
