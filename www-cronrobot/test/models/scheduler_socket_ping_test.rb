require "test_helper"

class SchedulerSocketPingTest < ActiveSupport::TestCase
  test "Create" do
    p = Project.last

    sched = SchedulerSocketPing.create!(project: p, schedule: "* * * * *")

    assert sched
  end
end
