
class ResourceScheduler < Resource
  validate :validate_scheduler_type
  validate :validate_required_params

  def scheduler
    Scheduler.find_by id: reference_id
  end

  TYPES = [
    "ResourceScheduler",
    "ResourceSchedulerHttp",
    "ResourceSchedulerSocketPing",
    "ResourceSchedulerSsh"
  ]

  def expected_scheduler_type
  end

  def expected_required_params
    []
  end

  def validate_scheduler_type
    if expected_scheduler_type && scheduler.type != expected_scheduler_type
      errors.add(:scheduler_type, "invalid scheduler type")
    end
  end

  def validate_required_params
    expected_required_params.each do |required_param_name|
      if params[required_param_name].blank?
        return errors.add(required_param_name.to_sym, "is missing")
      end
    end
  end
end
