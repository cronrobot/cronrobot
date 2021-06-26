
class Dashboard::SchedulerSocketPingsController < DashboardController
  def create
    
    @scheduler = SchedulerSocketPing.new(allowed_scheduler_socket_ping_params)

    if @scheduler.save
      redirect_to scheduler_socket_pings_path(@scheduler)
    else
      flash[:danger] = @scheduler.errors.full_messages
      redirect_back fallback_location: root_path
    end
  end

  private

  def allowed_scheduler_socket_ping_params
    params
    .require(:scheduler_socket_ping)
    .permit(:name, :schedule, :project_id)
  end
end
