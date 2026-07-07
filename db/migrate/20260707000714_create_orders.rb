class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :account, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.integer :status, default: 0, null: false
      t.integer :total_amount_cents, default: 0, null: false
      t.string :currency, default: "GBP", null: false
      t.text :notes
      t.references :user, null: true, foreign_key: true

      t.timestamps
    end
  end
end
