
require 'securerandom'

class AuthToken < ApplicationRecord
  encrypts :client_secret

  before_create :generate_keys

  def generate_keys
    self.client_id = SecureRandom.uuid unless self.client_id
    self.client_secret = SecureRandom.uuid
  end
end
