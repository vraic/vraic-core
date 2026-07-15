class CreateLoyaltyCard < ActiveRecord::Migration[8.1]
  def change
    create_table :loyalty_cards do |t|
      t.references :customer, null: false, foreign_key: true
      t.references :loyalty_program, null: false, foreign_key: true
      t.string :identifier
      t.integer :points_balance, default: 0

      t.timestamps
    end
    add_index :loyalty_cards, :identifier, unique: true
  end
end
