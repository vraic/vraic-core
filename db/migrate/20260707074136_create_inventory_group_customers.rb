class CreateInventoryGroupCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :inventory_group_customers do |t|
      t.references :inventory_group, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true

      t.timestamps
    end
  end
end
