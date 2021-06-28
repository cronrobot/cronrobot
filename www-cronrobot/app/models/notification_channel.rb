class NotificationChannel < ApplicationRecord
  self.inheritance_column = :my_type

  belongs_to :project

  serialize :configs, JSON
  
  encrypts :configs

  NOTIFICATION_CHANNEL_TYPES = %w(email )

  validates :type, :inclusion => {:in => NOTIFICATION_CHANNEL_TYPES}
end
