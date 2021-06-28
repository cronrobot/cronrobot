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
end
