class AddCollectionPointToLocations < ActiveRecord::Migration[8.1]
  def change
    add_column :locations, :collection_point, :boolean, default: false, null: false
  end
end
