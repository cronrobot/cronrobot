require "test_helper"

class SchedulerHttpTest < ActiveSupport::TestCase
  test "Create" do
    p = Project.last

    sched = SchedulerHttp.create!(
      project: p, schedule: "* * * * *", name: 's', updated_by_user_id: User.last.id
    )

    assert sched
  end
end