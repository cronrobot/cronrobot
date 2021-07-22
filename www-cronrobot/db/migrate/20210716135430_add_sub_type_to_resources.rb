class AddSubTypeToResources < ActiveRecord::Migration[7.0]
  def change
    add_column :resources, :sub_type, :string
  end
end
