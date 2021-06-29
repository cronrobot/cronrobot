class CreateNotificationChannels < ActiveRecord::Migration[7.0]
  def change
    create_table :notification_channels do |t|
      t.text :configs
      t.string :name
      t.references :project, null: false, foreign_key: true
      t.string :type

      t.timestamps
    end
  end
end
