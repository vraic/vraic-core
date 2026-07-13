class RemoveContentFromNewsletters < ActiveRecord::Migration[8.1]
  def change
    remove_column :newsletters, :content, :text
  end
end
