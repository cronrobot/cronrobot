class RemoveUserIdProjects < ActiveRecord::Migration[7.0]
  def change
    remove_column :projects, :user_id
  end
end
