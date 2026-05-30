class AddUserTypeAndAdminFlagsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :user_type, :integer, default: 1
    add_column :users, :admin, :boolean
  end
end
