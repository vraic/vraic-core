class AddCustomerAccountToCustomers < ActiveRecord::Migration[8.1]
  def change
    add_reference :customers, :customer_account, null: true, foreign_key: { to_table: :accounts }
  end
end
