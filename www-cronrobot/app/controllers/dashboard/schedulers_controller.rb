class Dashboard::SchedulersController < DashboardController

  before_action :validate_param_type
  before_action :load_friendly_schedules

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

  def delete
    scheduler = @current_user.schedulers.where(id: params["id"]).first
    scheduler.destroy!

    flash[:success] = "Scheduler removed successfully!"
    redirect_back fallback_location: root_path
  end

  private

  def validate_param_type
    if params["type"].present?
      valid_types = %w(SchedulerSocketPing SchedulerHttp SchedulerSsh)

      raise Exception.new("Invalid type") unless valid_types.include?(params["type"])

      @scheduler_klass = params["type"].constantize
    end
  end

  def load_friendly_schedules
    @friendly_schedules = [
      {
        name: "Custom",
        id: "custom"
      },
      {
        name: "Every minute",
        cron: "* * * * *",
        id: "every_minute"
      },
    ]
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