require "test_helper"

class SchedulerSocketPingTest < ActiveSupport::TestCase
  test "Create" do
    p = Project.last

    sched = SchedulerSocketPing.create!(project: p, schedule: "* * * * *")

    assert sched
  end

  test "update" do
    p = Project.last

    sched = SchedulerSocketPing.create!(project: p, schedule: "* * * * *")

    mock_find_celery_periodic_task(sched.id, 404)
    mock_create_celery_periodic_task(
      200,
      id: sched.id,
      task: "celery_admin.celery.socket_ping"
    )

    sched.touch!
  end
end
