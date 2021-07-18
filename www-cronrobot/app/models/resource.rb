
class Resource < ApplicationRecord
  serialize :params, JSON
  
  encrypts :params

  def self.accessible_by(user)
    user.schedulers.map { |s| s.resources + s.project.resources }.flatten.uniq
  end
end
