class AddTrackingToAhoyMessages < ActiveRecord::Migration[8.1]
  def change
    add_column :ahoy_messages, :opened_at, :datetime
    add_column :ahoy_messages, :clicked_at, :datetime
  end
end
