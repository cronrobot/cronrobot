
class ResourceSchedulerSocketPing < ResourceScheduler

  validate :validate_params
  validate :validate_scheduler_type

  def validate_params
    if params["port"].blank?
      return errors.add(:port, "Port is missing")
    end

    if params["host"].blank?
      return errors.add(:host, "Host is missing")
    end

    unless params["port"].to_i > 0 && params["port"].to_i <= 65535
      errors.add(:port, "Invalid port number")
    end
  end

  def validate_scheduler_type
    unless scheduler.type == "SchedulerSocketPing"
      errors.add(:scheduler_type, "Invalid scheduler type")
    end
  end
end
