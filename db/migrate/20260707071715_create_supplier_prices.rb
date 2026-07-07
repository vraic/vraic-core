class CreateSupplierPrices < ActiveRecord::Migration[8.1]
  def change
    create_table :supplier_prices do |t|
      t.references :inventory_item, null: false, foreign_key: true
      t.references :supplier, null: false, foreign_key: true
      t.integer :price_cents
      t.string :currency

      t.timestamps
    end
  end
end
