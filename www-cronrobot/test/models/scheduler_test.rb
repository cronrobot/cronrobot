require "test_helper"

class SchedulerTest < ActiveSupport::TestCase
  test "Create" do
    p = Project.last

    sched = Scheduler.create!(
      project: p,
      schedule: "* * * * *",
      name: 's',
      notification_channels: ["", "12"]
      )

    assert sched
    assert sched.notification_channels == ["12"]
  end
end
