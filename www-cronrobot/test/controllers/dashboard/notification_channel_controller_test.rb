require "test_helper"

class DashboardNotificationChannelsControllerTest < ActionDispatch::IntegrationTest

  setup do
    set_auth0
    default_user_project
  end

  test "new - happy path" do
    body = default_user_body

    get "/dashboard/notification_channels/new", params: body

    assert_response :ok
    assert_includes response.parsed_body, "<option value=\"discord\">"
    assert_includes response.parsed_body, "<option value=\"email\">"
  end

  test "show a notification channel" do
    channel = NotificationChannel.create!(
      project: @project,
      name: "notif-channel1",
      configs: {"addresses" => "my@email.com"},
      type: "email"
    )

    body = default_user_body
    scheduler = Scheduler.last

    get "/dashboard/notification_channels/#{channel.id}", params: body

    assert_response :ok
    assert_includes response.parsed_body, "value=\"my@email.com\""
    assert_includes response.parsed_body, "type=\"text\""
  end
end
