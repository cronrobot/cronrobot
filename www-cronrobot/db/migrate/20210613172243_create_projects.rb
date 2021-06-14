class CreateProjects < ActiveRecord::Migration[7.0]
  def change
    create_table :projects do |t|
      t.string :name
      t.string :user_id

      t.timestamps
    end

    add_index :projects, [:name, :user_id], unique: true
  end
end
