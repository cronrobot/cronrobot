class User < ApplicationRecord
  encrypts :grafana_password

  validates :uid, :grafana_password, :grafana_user_id, presence: true

  PASSWORD_CHARS = ('0'..'9').to_a + ('A'..'Z').to_a + ('a'..'z').to_a
  def self.random_password(length=10)
    PASSWORD_CHARS.sort_by { rand }.join[0...length]
  end
end