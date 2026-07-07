class CreateOrderItems < ActiveRecord::Migration[8.1]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :inventory_item, null: false, foreign_key: true
      t.integer :quantity, default: 1, null: false
      t.integer :price_cents, default: 0, null: false
      t.string :currency, default: "GBP", null: false

      t.timestamps
    end
  end
end
