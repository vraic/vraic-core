class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts do |t|
      t.string :name
      t.text :address
      t.integer :owner_id

      t.timestamps
    end
  end
end
