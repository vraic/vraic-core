class AddUserToSuppliers < ActiveRecord::Migration[8.1]
  def change
    add_reference :suppliers, :user, null: true, foreign_key: true
  end
end
