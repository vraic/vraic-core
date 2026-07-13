class CreateNewsletters < ActiveRecord::Migration[8.1]
  def change
    create_table :newsletters do |t|
      t.references :account, null: false, foreign_key: true
      t.string :subject
      t.text :content
      t.integer :target, default: 0, null: false
      t.datetime :sent_at

      t.timestamps
    end
  end
end
