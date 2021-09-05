
class ResourceProject < Resource
  belongs_to :project, foreign_key: :reference_id

  validates :project, presence: true
  validates :sub_type, presence: true

  SUB_TYPES = %w(ResourceProjectSsh ResourceProjectVariable)
  validates :sub_type, :inclusion => {:in => SUB_TYPES}

  before_destroy :ensure_not_used

  def ensure_not_used
    project.schedulers.each do |scheduler|
      scheduler.resources.each do |resource|
        if resource.params&.dig("resource_id").to_s == self.id.to_s
          raise Exception.new("Resource currently used by scheduler #{scheduler.name}")
        end
      end
    end
  end

end
