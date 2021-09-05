
module SshResource
  def init_params
    params["port"] = 22 unless params["port"].present?
  end

  def validate_params
    unless params&.dig("host").present?
      errors.add(:host, "missing")
    end

    unless params&.dig("username").present?
      errors.add(:username, "missing")
    end

    # private key OR password-based (todo)
    if params&.dig("private_key").blank?
      errors.add(:ssh_credentials, "missing")
    end
  end
end
