class AddParentResourceIdToResources < ActiveRecord::Migration[7.0]
  def change
    add_reference :resources, :parent_resource, foreign_key: { to_table: :resources }
  end
end
