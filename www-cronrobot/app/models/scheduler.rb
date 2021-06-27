class Scheduler < ApplicationRecord
  belongs_to :project
  has_many :resources,
           foreign_key: :reference_id,
           class_name: :ResourceScheduler,
           dependent: :destroy

  attr_accessor :params

  validates :name, presence: true

  before_destroy :process_destroy
  after_save :store_params

  def accessible_by_users
    [project.user]
  end

  def store_params
    if self.params.present?
      if resources.exists?
        resource = resources.first
        resource.params = params
        resource.save
      else
        klass = "Resource#{self.type}".constantize
        resource = klass.create(reference_id: id, params: params)
      end
      
      errors.add(:params, "Invalid parameters: #{resource.errors.full_messages}") unless resource.valid?
    end
  end

  def touch!
    process_upsert
    touch
  end

  def celery_task
    raise "not implemented"
  end

  def process_upsert
    begin
      result_celery = Celery.upsert_periodic_task(self)
      result_upsert_grafana_dashboard = Grafana.upsert_dashboard(self)
      result_update_permissions = Grafana.update_dashboard_permissions(
        self,
        accessible_by_users
      )

      {
        result_celery: result_celery,
        result_upsert_grafana_dashboard: result_upsert_grafana_dashboard,
        result_update_permissions: result_update_permissions
      }
    rescue Exception => e
      Rails.logger.error("Issue upsert: #{e}")
      errors.add(:scheduler, "update error - #{e}")
    end
  end

  def process_destroy
    if Celery.periodic_task_exists?(id)
      Celery.delete("/periodic-tasks/#{Celery.periodic_task_name(id)}/")
    end

    if Grafana.dashboard_exists?(self)
      Grafana.destroy_dashboard(self)
    end
  end

end
