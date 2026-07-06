class DropStudents < ActiveRecord::Migration[8.1]
  def change
    drop_table :students
  end
end
