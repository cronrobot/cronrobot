require "test_helper"

class DashboardNotificationChannelsControllerTest < ActionDispatch::IntegrationTest

  setup do
    set_auth0
  end

  test "happy path - email" do
    current_user = User.last
    current_user.uid = "1234"
    current_user.save!
    project = Project.last
    project.user = current_user
    project.save!

    channel = NotificationChannel.create!(
      project: project,
      name: "notif-channel1",
      configs: {"addresses" => "my@email.com"},
      type: "email"
    )

    body = {
      "userinfo" => {
        "sub" => "1234"
      },
      "selected_project_id": project.id
    }
    scheduler = Scheduler.last

    get "/dashboard/notification_channels/#{channel.id}", params: body

    assert_response :ok
    assert_includes response.parsed_body, "value=\"my@email.com\""
    assert_includes response.parsed_body, "type=\"text\""
  end
end
