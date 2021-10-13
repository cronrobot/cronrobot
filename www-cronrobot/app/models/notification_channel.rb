class NotificationChannel < ApplicationRecord
  self.inheritance_column = :my_type

  belongs_to :project

  serialize :configs, JSON
  
  encrypts :configs

  def self.config_types
    NotificationChannel.configs.keys.map { |k| k.to_s }
  end

  def self.configs
    Rails.application.config_for(:notification_channels)
  end

  def config
    NotificationChannel.configs[type]
  end

  NOTIFICATION_CHANNEL_TYPES = %w(email )

  validates :type, :inclusion => {:in => NotificationChannel.config_types}

  before_update :upsert_grafana_notification_channel
  before_destroy :destroy_grafana_notification_channel

  def upsert_grafana_notification_channel
    begin
      Grafana.upsert_notification_channel(self)
    rescue Exception => e
      Rails.logger.error("Issue upsert: #{e}")
      errors.add(:channel, "update error - #{e}")
    end
  end

  def destroy_grafana_notification_channel
    Grafana.destroy_notification_channel(self)
  end
end
