class CreateLoyaltyProgram < ActiveRecord::Migration[8.1]
  def change
    create_table :loyalty_programs do |t|
      t.references :account, null: false, foreign_key: true
      t.decimal :points_to_currency_ratio, precision: 10, scale: 2, default: 0.1
      t.integer :currency_to_points_ratio, default: 1
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
