class AddWarnWhenLowOnStockToInventoryItems < ActiveRecord::Migration[8.1]
  def change
    add_column :inventory_items, :warn_when_low_on_stock, :boolean, default: false, null: false
    add_column :inventory_items, :low_stock_threshold, :integer, default: 0, null: false
  end
end
