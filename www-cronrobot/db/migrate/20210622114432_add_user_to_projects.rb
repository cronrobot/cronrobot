class AddUserToProjects < ActiveRecord::Migration[7.0]
  def change
    #add_column :projects, :user_id, :integer
    add_reference :projects, :user, foreign_key: true
  end
end
