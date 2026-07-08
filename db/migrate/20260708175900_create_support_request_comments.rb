class CreateSupportRequestComments < ActiveRecord::Migration[8.0]
  def change
    create_table :support_request_comments do |t|
      t.belongs_to :support_request, null: false, foreign_key: true
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :account, null: false, foreign_key: true
      t.text :body

      t.timestamps
    end
  end
end
