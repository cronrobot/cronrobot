
class ResourceProjectSsh < ResourceProject
  include SshResource
  self.inheritance_column = :sub_type

  before_validation :init_params
  validate :validate_params

  
end
