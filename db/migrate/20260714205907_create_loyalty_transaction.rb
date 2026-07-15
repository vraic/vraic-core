class CreateLoyaltyTransaction < ActiveRecord::Migration[8.1]
  def change
    create_table :loyalty_transactions do |t|
      t.references :loyalty_card, null: false, foreign_key: true
      t.references :order, null: true, foreign_key: true
      t.integer :amount, null: false
      t.integer :transaction_type, null: false, default: 0
      t.string :description

      t.timestamps
    end
  end
end
