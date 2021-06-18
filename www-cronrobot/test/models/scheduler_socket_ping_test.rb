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
      task: "celery_admin.celery.socket_ping",
      schedule: "%2A%20%2A%20%2A%20%2A%20%2A"
    )

    sched.touch!
  end

  test "update - fail if non status code 200" do
    p = Project.last

    sched = SchedulerSocketPing.create!(project: p, schedule: "* * * * *")

    mock_find_celery_periodic_task(sched.id, 404)
    mock_create_celery_periodic_task(
      400,
      id: sched.id,
      task: "celery_admin.celery.socket_ping",
      schedule: "%2A%20%2A%20%2A%20%2A%20%2A"
    )

    assert_raises Exception do
      sched.touch!
    end
  end

  test "create then delete" do
    p = Project.last

    sched = SchedulerSocketPing.create!(project: p, schedule: "* * * * *")

    mock_find_celery_periodic_task(sched.id, 200)
    mock_delete_celery_periodic_task(sched.id)

    sched.destroy
  end
end
