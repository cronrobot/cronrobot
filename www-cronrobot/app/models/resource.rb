
class Resource < ApplicationRecord
  serialize :params, JSON
  
  encrypts :params

  def self.accessible_by(user, of_type=nil)
    result = (user.schedulers.map { |s| s.resources }.flatten +
      user.projects.map { |p| p.resources }.flatten)
      .uniq

    if of_type.present?
      result = result.select { |r| r["type"] == of_type || r["sub_type"] == of_type }
    end

    result
  end
end
