class ChangeInventoryLevelsQuantityToInteger < ActiveRecord::Migration[8.1]
  def up
    change_column :inventory_levels, :quantity, :integer, default: 0
  end

  def down
    change_column :inventory_levels, :quantity, :decimal, precision: 10, scale: 2, default: 0
  end
end
