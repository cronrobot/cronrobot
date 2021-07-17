
class ResourceSchedulerSsh < ResourceScheduler
  include SshResource

  before_validation :init_params
  validate :validate_params

end
