
class ResourceProjectSsh < ResourceProject
  self.inheritance_column = :sub_type

  before_validation :init_params
  validate :validate_params

  def init_params
    params["port"] = 22 unless params["port"].present?
  end

  def validate_params
    unless params["host"].present?
      errors.add(:host, "missing")
    end

    unless params["username"].present?
      errors.add(:username, "missing")
    end

    # private key OR password-based (todo)
    if params["private_key"].blank?
      errors.add(:ssh_credentials, "missing")
    end
  end
end
