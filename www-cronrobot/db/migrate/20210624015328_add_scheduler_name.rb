class AddSchedulerName < ActiveRecord::Migration[7.0]
  def change
    add_column :schedulers, :name, :string
  end
end
