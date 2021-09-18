class Dashboard::SchedulersController < DashboardController

  def set_current_section
    @section = "scheduler"
  end

  before_action :validate_param_type
  before_action :authorize_scheduler_access

  def index
    @schedulers = @current_user.schedulers.order(id: :desc)
    @alerts_statuses = prepare_alerts_statuses(@schedulers)
  end

  def new
    @scheduler = @scheduler_klass.new
    @scheduler.project_id = @project.id
    @notification_channels = @current_user.notification_channels

    render template: "dashboard/schedulers/#{@scheduler_klass}"
  end

  def pause
    scheduler = access_param_scheduler(params["id"])
    scheduler.pause!(true, "manual")

    flash[:success] = "Scheduler successfully paused!"
    redirect_back fallback_location: root_path
  end

  def unpause
    scheduler = access_param_scheduler(params["id"])
    scheduler.unpause!

    flash[:success] = "Scheduler successfully resumed!"
    redirect_back fallback_location: root_path
  end

  def delete
    scheduler = access_param_scheduler(params["id"])
    scheduler.destroy!

    flash[:success] = "Scheduler removed successfully!"
    redirect_back fallback_location: root_path
  end

  def update
    handle_update
  end

  protected

  def access_param_scheduler(id)
    scheduler = @current_user.schedulers.where(id: id).first
    scheduler.updated_by_user_id = @current_user.id
    scheduler
  end

  def authorize_scheduler_access
    scheduler_id = params["id"]

    if scheduler_id.present?
      @scheduler = Scheduler.find(scheduler_id)
      @scheduler.params = @scheduler.stored_params
      scheduler_accessible_to!(@scheduler)
    end
  end

  def scheduler_accessible_to!(scheduler)
    unless @current_user.schedulers.include?(scheduler)
      raise User::AuthorizationError.new("Cannot access the scheduler")
    end
  end

  private

  def validate_param_type
    if params["type"].present?
      valid_types = %w(SchedulerSocketPing SchedulerHttp SchedulerSsh)

      raise Exception.new("Invalid type") unless valid_types.include?(params["type"])

      @scheduler_klass = params["type"].constantize
    end
  end

  def prepare_alerts_statuses(schedulers)
    grafana_dashboard_ids = schedulers
      .map { |s| s.grafana_dashboard_id }
      .select { |s| s }

    alerts = Grafana.dashboards_alerts(grafana_dashboard_ids)

    result = {}

    alerts.each do |alert|
      result[alert["dashboardUid"].to_i] = alert
    end

    result
  end

end