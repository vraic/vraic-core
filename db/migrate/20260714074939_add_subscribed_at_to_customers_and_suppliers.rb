class AddSubscribedAtToCustomersAndSuppliers < ActiveRecord::Migration[8.1]
  def change
    add_column :customers, :subscribed_at, :datetime
    add_column :suppliers, :subscribed_at, :datetime
  end
end
