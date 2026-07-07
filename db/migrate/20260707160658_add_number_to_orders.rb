class AddNumberToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :number, :string
    add_index :orders, :number, unique: true
  end
end
