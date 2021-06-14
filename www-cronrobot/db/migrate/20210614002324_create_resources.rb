class CreateResources < ActiveRecord::Migration[7.0]
  def change
    create_table :resources do |t|
      t.string :type
      t.integer :reference_id
      t.text :params

      t.timestamps
    end
  end
end
