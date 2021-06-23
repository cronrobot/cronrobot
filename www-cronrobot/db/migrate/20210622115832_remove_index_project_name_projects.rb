class RemoveIndexProjectNameProjects < ActiveRecord::Migration[7.0]
  def change
    remove_index :projects, name: "index_projects_on_name_and_user_id"
  end
end
