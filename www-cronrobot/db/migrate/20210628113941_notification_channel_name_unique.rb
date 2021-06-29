class NotificationChannelNameUnique < ActiveRecord::Migration[7.0]
  def change
    add_index :notification_channels, [:name, :project_id], unique: true
  end
end
