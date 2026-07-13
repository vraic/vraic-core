class AddNewsletterIdToAhoyMessages < ActiveRecord::Migration[8.1]
  def change
    add_reference :ahoy_messages, :newsletter, null: false, foreign_key: true
  end
end
