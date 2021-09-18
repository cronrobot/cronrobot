
class Dashboard::NotificationChannelsController < DashboardController

  def set_current_section
    @section = "notification_channel"
  end

  def index
    @notification_channels = @current_user.notification_channels
  end

  def new
    @notification_channel = NotificationChannel.new
    @notification_channel.project_id = @project.id
  end

  def create
    ch = NotificationChannel.create!(allowed_notification_channel_params)

    flash[:success] = "Scheduler successfully saved!"
    redirect_to action: :update, id: ch.id
  end

  def update
    @notification_channel = @current_user.notification_channels.find(params["id"])
    @notification_channel.update!(allowed_notification_channel_params)

    redirect_to action: :index
  end

  def destroy
    @notification_channel = @current_user.notification_channels.find(params["id"])
    @notification_channel.destroy!

    redirect_to action: :index
  end

  def show
    @notification_channel = @current_user.notification_channels.find(params["id"])
    @notification_channel.configs ||= {}
  end

  private

  def allowed_notification_channel_params
    params
    .require(:notification_channel)
    .permit(:name, :type, :project_id, configs: {})
  end
end
