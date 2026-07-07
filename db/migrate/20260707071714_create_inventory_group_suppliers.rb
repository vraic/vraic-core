class CreateInventoryGroupSuppliers < ActiveRecord::Migration[8.1]
  def change
    create_table :inventory_group_suppliers do |t|
      t.references :inventory_group, null: false, foreign_key: true
      t.references :supplier, null: false, foreign_key: true

      t.timestamps
    end
  end
end
