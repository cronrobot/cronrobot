class Scheduler < ApplicationRecord
  belongs_to :project

  def resources
    Resource.where(reference_id: id, type: ResourceScheduler::TYPES)
  end

  attr_accessor :params
  serialize :notification_channels, JSON

  validates :name, presence: true
  validate :verify_params_resource_access

  before_destroy :process_destroy
  before_save :clean_notification_channels
  after_save :store_params

  def stored_params
    resource = resources.first

    resource&.params || {}
  end

  def plural_path_name
    raise "Undefined"
  end

  def accessible_by_users
    [project.user]
  end

  def updated_by_user
    User.find(updated_by_user_id)
  end

  def verify_params_resource_access
    if self.params&.dig("resource_id").present?
      resource = Resource.find(params["resource_id"])

      if ! Resource.accessible_by(updated_by_user).include?(resource)
        raise User::AuthorizationError.new("Unauthorized")
      end
    end
  end

  def store_params_from_template
    # the template is passed in params["resource_id"]

    if self.params.present?

      # the parent resource has already been authorized here
      template_resource = Resource.find(params["resource_id"])

      if resources.exists?
        resource = resources.first

        resource.params = resource.params.merge(
          params.merge(template_resource.params) || {}
        )
        resource.parent_resource_id = template_resource.id
        
        resource.save
      else
        klass = "Resource#{self.type}".constantize
        params = self.params.merge(template_resource.params)
        resource = klass.create(
          reference_id: id, params: params, parent_resource_id: template_resource.id
        )
      end
      
      errors.add(:params, "Invalid parameters: #{resource.errors.full_messages}") unless resource.valid?
    end
  end

  def clean_notification_channels
    self.notification_channels = [] unless notification_channels

    self.notification_channels = self.notification_channels.select { |ch| ch.present? }
  end

  def store_params
    puts "store params.."
    if self.params.present?
      puts " pres"

      if resources.exists?
        puts " res ex"
        resource = resources.first
        puts "resources #{resources.inspect}"
        resource.params = params
        resource.save
      else
        puts " res crea"
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
    raise "celery_task not implemented"
  end

  def default_grafana_template
    "Scheduler"
  end

  def process_upsert
    begin
      result_celery = Celery.upsert_periodic_task(self)
      result_upsert_grafana_dashboard = Grafana.upsert_dashboard(self)

      grafana_dashboard_response = JSON.parse(result_upsert_grafana_dashboard.body)
      self.grafana_dashboard_id = grafana_dashboard_response["id"]
      save!

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

  def pause!(should_pause = true, pause_state="")
    # Grafana alert:
    alert_id = Grafana.dashboards_alerts([self.grafana_dashboard_id]).first&.dig("id")

    return unless alert_id

    result = Grafana.pause_alert(alert_id, should_pause)

    enable_periodic_task(!should_pause)

    self.pause_state = pause_state
    save!

    result
  end

  def enable_periodic_task(should_enable = true)
    # celery periodic task
    periodic_task = Celery.get_json(
      "/periodic-tasks/find?name=#{Celery.periodic_task_name(id)}"
    )

    periodic_task_id = periodic_task&.dig("id")

    enable_route = should_enable ? "enable" : "disable"

    # enable or disable
    Celery.post("/periodic-tasks/#{periodic_task_id}/#{enable_route}", '{}')
  end

  def unpause!(pause_state="")
    pause!(false, pause_state)
  end

end
