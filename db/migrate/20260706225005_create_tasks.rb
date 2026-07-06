class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.string :title
      t.text :description
      t.references :account, null: false, foreign_key: true
      t.references :responsible_user, null: false, foreign_key: { to_table: :users }
      t.references :assigned_by, null: false, foreign_key: { to_table: :users }
      t.date :due_date

      t.timestamps
    end
  end
end
