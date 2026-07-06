class RemoveColumnFromUser < ActiveRecord::Migration[8.1]
  def change
    remove_column :users, :user_type
  end
end
