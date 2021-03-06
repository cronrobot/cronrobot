
class Dashboard::NotificationChannelsController < DashboardController

  def set_current_section
    @section = "notification_channel"
  end

  def index
    @notification_channels = @current_user
      .notification_channels
      .select { |nc| nc.project_id == @project.id }
  end

  def new
    @notification_channel = NotificationChannel.new
    @notification_channel.project_id = @project.id

    configs = notification_channel_configs
    @notification_channel_types = NotificationChannel.config_types
  end

  def create
    ch = NotificationChannel.create!(allowed_notification_channel_params)

    flash[:success] = "Notification channel successfully created!"
    redirect_to action: :update, id: ch.id
  end

  def update
    @notification_channel = @current_user.notification_channels.find(params["id"])
    @notification_channel.update!(allowed_notification_channel_params)

    # Run a test if the test btn was clicked
    if params["commit"] == "Save and Test"
      @notification_channel.test_grafana_notification_channel
    end

    flash[:success] = "Notification channel successfully saved!"
    redirect_to action: :index
  end

  def destroy
    @notification_channel = @current_user.notification_channels.find(params["id"])
    @notification_channel.destroy!

    flash[:success] = "Notification channel removed!"
    redirect_to action: :index
  end

  def show
    @notification_channel = @current_user.notification_channels.find(params["id"])
    @notification_channel.configs ||= {}

    configs = notification_channel_configs
    @fields = configs[@notification_channel.type][:fields]
  end

  private

  def notification_channel_configs
    NotificationChannel.configs
  end

  def allowed_notification_channel_params
    params
    .require(:notification_channel)
    .permit(:name, :type, :project_id, configs: {})
  end
end
