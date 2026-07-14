class AddUniqueIndexToAccountUsers < ActiveRecord::Migration[8.1]
  def up
    # Remove duplicates before adding index
    execute <<-SQL
      DELETE FROM account_users#{' '}
      WHERE id NOT IN (
        SELECT MIN(id)#{' '}
        FROM account_users#{' '}
        GROUP BY account_id, user_id
      )
    SQL
    add_index :account_users, [ :account_id, :user_id ], unique: true
  end

  def down
    remove_index :account_users, [ :account_id, :user_id ]
  end
end
