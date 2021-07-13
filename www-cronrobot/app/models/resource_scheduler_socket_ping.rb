
class ResourceSchedulerSocketPing < ResourceScheduler
  before_validation :clean_params

  validate :validate_params

  def expected_scheduler_type
    "SchedulerSocketPing"
  end

  def expected_required_params
    ["port", "host"]
  end

  def validate_params
    unless params["port"].to_i > 0 && params["port"].to_i <= 65535
      errors.add(:port, "invalid port number")
    end
  end

  def clean_params
    if params["port"].present?
      params["port"] = params["port"].to_i
    end
  end
end
