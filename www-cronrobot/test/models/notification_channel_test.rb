require "test_helper"

class NotificationChannelTest < ActiveSupport::TestCase
  test "create" do
    p = Project.last
    ch = NotificationChannel.create!(
      project: p, name: "channel3", configs: {"c1" => "v1"}, type: "email"
    )

    assert ch.valid?
  end

  test "unique by name" do
    p = Project.last

    assert_raises Exception do 
      NotificationChannel.create(
        project: p, name: "channel1", configs: {"c1" => "v1"}, type: "email"
      )
    end
  end

  test "update - happy path" do
    p = Project.last
    ch = NotificationChannel.create!(
      project: p, name: "channel3", configs: {"c1" => "v1"}, type: "email"
    )

    ch.configs = {}
    ch.configs["addresses"] = "test@mail.com"
    ch.name = "what"

    mock_get_grafana_notification_channel(ch, 200)
    request_body = "{\"uid\":\"#{ch.id}\",\"type\":\"email\",\"name\":\"notification-channel-#{ch.id}\",\"settings\":{\"addresses\":\"test@mail.com\"}}"
    mock_update_grafana_notification_channel(ch, 200, request_body)

    ch.save
    
    assert ch.errors.count == 0
  end
end
