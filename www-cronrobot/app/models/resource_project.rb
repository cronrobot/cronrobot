
class ResourceProject < Resource
  belongs_to :project, foreign_key: :reference_id

  validates :project, presence: true
  validates :sub_type, presence: true
  validate :name_unique_by_project

  SUB_TYPES = %w(ResourceProjectVariable ResourceProjectSsh)
  validates :sub_type, :inclusion => {:in => SUB_TYPES}

  after_save :update_scheduler_resources
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

  def update_scheduler_resources
    resources = Resource.where(parent_resource_id: self.id)

    resources.each do |resource|
      scheduler = resource.scheduler

      unless scheduler.present?
        next
      end

      scheduler.params ||= {}
      scheduler.params["resource_id"] = self.id
      scheduler.store_params
    end
  end

  def name_unique_by_project
    if project.present?
      resource_name_exists = project.resources.any? do |r|
        r.params.dig("name") == self.params.dig("name") and self != r
      end

      if resource_name_exists
        errors.add(:name, "resource name already exists")
      end
    end
  end

end
