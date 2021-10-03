
class ResourceSchedulerSsh < ResourceScheduler
  include SshResource

  before_validation :init_params
  validate :validate_params

  def expected_scheduler_type
    "SchedulerSsh"
  end

end
