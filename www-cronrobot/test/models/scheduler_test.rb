require "test_helper"

class SchedulerTest < ActiveSupport::TestCase
  test "Create" do
    p = Project.last

    sched = Scheduler.create!(project: p, schedule: "* * * * *")

    assert sched
  end
end
