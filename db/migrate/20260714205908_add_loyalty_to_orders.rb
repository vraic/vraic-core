class AddLoyaltyToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :loyalty_points_redeemed, :integer, default: 0
    add_column :orders, :loyalty_discount_amount_cents, :integer, default: 0
  end
end
