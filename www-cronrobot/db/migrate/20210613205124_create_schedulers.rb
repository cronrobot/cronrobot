class CreateSchedulers < ActiveRecord::Migration[7.0]
  def change
    create_table :schedulers do |t|
      t.string :type
      t.string :schedule
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
