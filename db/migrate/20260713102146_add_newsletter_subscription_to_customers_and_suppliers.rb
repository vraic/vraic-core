class AddNewsletterSubscriptionToCustomersAndSuppliers < ActiveRecord::Migration[8.1]
  def change
    add_column :customers, :subscribed_to_newsletter, :boolean, default: false, null: false
    add_column :suppliers, :subscribed_to_newsletter, :boolean, default: false, null: false
  end
end
