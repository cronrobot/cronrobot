class AddNotificationChannelsToSchedulers < ActiveRecord::Migration[7.0]
  def change
    add_column :schedulers, :notification_channels, :text
  end
end
