
class Dashboard::SchedulerSshesController < Dashboard::SchedulersController

  def create
    @scheduler = SchedulerSsh.new()
    handle_update
  end

  def show
    @notification_channels = @current_user.notification_channels

    render template: "dashboard/schedulers/SchedulerSsh"
  end

  protected

  def handle_update
    @scheduler.attributes = allowed_params
    @scheduler.updated_by_user_id = @current_user.id
    @scheduler.save && @scheduler.errors.count.zero? && @scheduler.touch!

    if @scheduler.errors.count.positive?
      if @scheduler.id.present?
        flash[:danger] = @scheduler.errors.full_messages
        redirect_to dashboard_scheduler_ssh_path(@scheduler)
      else
        flash[:danger] = @scheduler.errors.full_messages
        redirect_back fallback_location: root_path
      end
    else
      flash[:success] = "Scheduler successfully saved!"
      redirect_to "/dashboard/schedulers"
    end
  end

  private

  def allowed_params
    params
    .require(:scheduler_ssh)
    .permit(:name, :schedule, :project_id, params: {}, notification_channels: [])
  end
end
