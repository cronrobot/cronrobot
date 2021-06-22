class AddIndexProjectNameProjects < ActiveRecord::Migration[7.0]
  def change
    add_index :projects, [:name, :user_id], unique: true
  end
end
