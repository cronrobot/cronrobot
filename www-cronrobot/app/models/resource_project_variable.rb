
class ResourceProjectVariable < ResourceProject
  include SshResource
  self.inheritance_column = :sub_type
  
  validate :validate_params

  def validate_params
    unless params["value"].present?
      errors.add(:value, "missing")
    end
  end
end
