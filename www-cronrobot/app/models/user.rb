class User < ApplicationRecord
  AuthorizationError = Class.new(StandardError)
  ForbiddenError = Class.new(StandardError)

  has_many :projects

  encrypts :grafana_password

  validates :uid, :grafana_user_id, presence: true

  PASSWORD_CHARS = ('0'..'9').to_a + ('A'..'Z').to_a + ('a'..'z').to_a
  def self.random_password(length=10)
    PASSWORD_CHARS.sort_by { rand }.join[0...length]
  end

  def self.can_access_project(user, project)
    unless user.projects.include?(project)
      raise User::AuthorizationError.new("Can't access project")
    end

    true
  end

  def schedulers
    project_ids = projects.pluck(:id)
    Scheduler.where(project_id: project_ids)
  end

  def notification_channels
    project_ids = projects.pluck(:id)
    NotificationChannel.where(project_id: project_ids)
  end
end
