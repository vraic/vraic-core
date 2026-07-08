class CreateSupportRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :support_requests do |t|
      t.belongs_to :account, null: false, foreign_key: true
      t.belongs_to :requester, null: false, foreign_key: { to_table: :users }
      t.integer :status
      t.text :message

      t.timestamps
    end
  end
end
