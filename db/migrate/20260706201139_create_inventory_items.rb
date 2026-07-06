class CreateInventoryItems < ActiveRecord::Migration[8.1]
  def change
    create_table :inventory_items do |t|
      t.string :name
      t.text :description
      t.integer :price_cents
      t.string :price_currency
      t.references :account, null: false, foreign_key: true
      t.references :inventory_group, null: true, foreign_key: true
      t.references :parent, null: true, foreign_key: { to_table: :inventory_items }
      t.integer :unit_type, default: 0 # per_unit: 0, per_weight: 1
      t.decimal :weight_value, precision: 10, scale: 2
      t.string :weight_unit
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :inventory_items, :deleted_at
  end
end
