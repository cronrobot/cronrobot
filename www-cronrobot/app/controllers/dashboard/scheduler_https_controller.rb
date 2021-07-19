
class Dashboard::SchedulerHttpsController < DashboardController
  def create
    @scheduler = SchedulerHttp.new(allowed_scheduler_http_params)
    @scheduler.updated_by_user_id = @current_user.id
    @scheduler.save && @scheduler.errors.count.zero? && @scheduler.touch!

    if @scheduler.errors.count.positive?
      if @scheduler.id.present?
        flash[:danger] = @scheduler.errors.full_messages
        redirect_to dashboard_scheduler_http_path(@scheduler)
      else
        flash[:danger] = @scheduler.errors.full_messages
        redirect_back fallback_location: root_path
      end
    else
      flash[:success] = "Scheduler successfully saved!"
      redirect_to "/dashboard/schedulers"
    end
  end

  def show
    @scheduler = Scheduler.find_by id: params["id"]
    @notification_channels = @current_user.notification_channels

    render template: "dashboard/schedulers/SchedulerHttp"
  end

  private

  def allowed_scheduler_http_params
    params
    .require(:scheduler_http)
    .permit(:name, :schedule, :project_id, params: {}, notification_channels: [])
  end
end
