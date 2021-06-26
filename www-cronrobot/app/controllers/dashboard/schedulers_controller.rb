class Dashboard::SchedulersController < DashboardController

  before_action :validate_param_type

  def index

  end

  def new
    @scheduler = @scheduler_klass.new
    @scheduler.project_id = @project.id

    render template: "dashboard/schedulers/#{@scheduler_klass}"
  end

  private

  def validate_param_type
    if params["type"].present?
      valid_types = %w(SchedulerSocketPing SchedulerHttp)

      raise Exception.new("Invalid type") unless valid_types.include?(params["type"])

      @scheduler_klass = params["type"].constantize
    end
  end

end