
class Dashboard::SchedulerSocketPingsController < Dashboard::SchedulersController

  def create
    @scheduler = SchedulerSocketPing.new()
    
    handle_update
  end

  def show
    @notification_channels = @current_user.notification_channels

    render template: "dashboard/schedulers/SchedulerSocketPing"
  end

  protected

  def handle_update
    @scheduler.attributes = allowed_scheduler_socket_ping_params
    @scheduler.updated_by_user_id = @current_user.id
    @scheduler.save && @scheduler.errors.count.zero? && @scheduler.touch!

    if @scheduler.errors.count.positive?
      if @scheduler.id.present?
        flash[:danger] = @scheduler.errors.full_messages
        redirect_to dashboard_scheduler_socket_ping_path(@scheduler)
      else
        flash[:danger] = @scheduler.errors.full_messages
        redirect_back fallback_location: root_path
      end
    else
      flash[:success] = "Scheduler successfully saved!"
      redirect_to "/dashboard/schedulers"
    end
  end

  def allowed_scheduler_socket_ping_params
    params
    .require(:scheduler_socket_ping)
    .permit(:name, :schedule, :project_id, params: {}, notification_channels: [])
  end
end
