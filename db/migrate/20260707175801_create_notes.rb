class CreateNotes < ActiveRecord::Migration[8.1]
  def change
    create_table :notes do |t|
      t.belongs_to :account, null: false, foreign_key: true
      t.belongs_to :user, null: false, foreign_key: true
      t.references :notable, polymorphic: true, null: false
      t.text :content

      t.timestamps
    end
  end
end
