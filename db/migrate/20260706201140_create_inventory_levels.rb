class CreateInventoryLevels < ActiveRecord::Migration[8.1]
  def change
    create_table :inventory_levels do |t|
      t.references :inventory_item, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.decimal :quantity, precision: 10, scale: 2, default: 0

      t.timestamps
    end
  end
end
