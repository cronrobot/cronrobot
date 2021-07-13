require "test_helper"

class SchedulerHttpTest < ActiveSupport::TestCase
  test "Create" do
    p = Project.last

    sched = SchedulerHttp.create!(project: p, schedule: "* * * * *", name: 's')

    assert sched
  end
end