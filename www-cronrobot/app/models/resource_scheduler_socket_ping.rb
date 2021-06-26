
class ResourceSchedulerSocketPing < ResourceScheduler

  validate :validate_params
  validate :validate_scheduler_type

  def validate_params
    if params["port"].blank?
      return errors.add(:port, "is missing")
    end

    if params["host"].blank?
      return errors.add(:host, "is missing")
    end

    unless params["port"].to_i > 0 && params["port"].to_i <= 65535
      errors.add(:port, "invalid port number")
    end
  end

  def validate_scheduler_type
    unless scheduler.type == "SchedulerSocketPing"
      errors.add(:scheduler_type, "invalid scheduler type")
    end
  end
end
