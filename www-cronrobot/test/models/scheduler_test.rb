require "test_helper"

class SchedulerTest < ActiveSupport::TestCase
  test "Create" do
    p = Project.last

    sched = Scheduler.create!(
      project: p,
      schedule: "* * * * *",
      name: 's',
      notification_channels: ["", "12"],
      updated_by_user_id: User.last.id
      )

    assert sched
    assert sched.notification_channels == ["12"]
  end

  test "Create - with resource id" do
    p = Project.last

    user = User.last

    resource = ResourceProjectSsh.create!(
      project: p,
      type: "ResourceProject",
      params: {
        param1: 123, host: "localhost", username: "user", private_key: "private_key"
      }
    )

    s = Scheduler.last
    s.project_id = p.id
    s.updated_by_user_id = user.id
    s.save!

    p.user = user
    p.save!

    resources = Resource.accessible_by(user)

    sched = Scheduler.create(
      project: p,
      schedule: "* * * * *",
      name: 's',
      notification_channels: ["", "12"],
      updated_by_user_id: user.id,
      params: { "resource_id" => resources.last.id }
      )

    assert sched.valid?
  end

  test "Create - with unauthorized resource id should fail" do
    p = Project.last

    user = User.last

    resources = Resource.accessible_by(user)

    assert resources.count.zero?

    assert_raises User::AuthorizationError do
      Scheduler.create(
        project: p,
        schedule: "* * * * *",
        name: 's',
        notification_channels: ["", "12"],
        updated_by_user_id: user.id,
        params: { "resource_id" => Resource.last.id }
      )
    end
  end

  test "Create - store params from template resource" do
    p = Project.last

    user = User.last

    params = {
      "param1" => 123,
      "host" => "localhost",
      "username" => "user",
      "private_key" => "private_key"
    }

    resource = ResourceProjectSsh.create!(
      project: p,
      type: "ResourceProject",
      params: params
    )

    s = Scheduler.last
    s.project_id = p.id
    s.updated_by_user_id = user.id
    s.save!

    p.user = user
    p.save!

    resources = Resource.accessible_by(user)
    assert resources.include?(ResourceProject.find(resource.id))
    
    new_scheduler = SchedulerSsh.create!(
      project: p,
      schedule: "* * * * *",
      name: 's',
      notification_channels: ["", "12"],
      updated_by_user_id: user.id,
      params: { "resource_id" => Resource.last.id }
    )

    resource_scheduler = new_scheduler.resources.reload.last
    
    assert resource_scheduler.params["param1"] == 123
    assert resource_scheduler.params["host"] == "localhost"
    assert resource_scheduler.params["username"] == "user"
    assert resource_scheduler.params["private_key"] == "private_key"
  end

  test "pause - happy path" do
    s = Scheduler.last
    s.updated_by_user_id = User.last.id
    s.grafana_dashboard_id = "9"
    s.save!

    mock_grafana_dashboard_alerts(s, 200, response: '[{"id": 55}]')
    mock_grafana_dashboard_alert_pause(55, 200, response: '{}', should_pause: true)
    mock_find_celery_periodic_task(s.id, 200, '{"id": 115}')
    mock_disable_celery_periodic_task(115)

    s.pause!
  end

  test "pause - with pause state" do
    s = Scheduler.last
    s.updated_by_user_id = User.last.id
    s.grafana_dashboard_id = "9"
    s.save!

    mock_grafana_dashboard_alerts(s, 200, response: '[{"id": 55}]')
    mock_grafana_dashboard_alert_pause(55, 200, response: '{}', should_pause: true)
    mock_find_celery_periodic_task(s.id, 200, '{"id": 115}')
    mock_disable_celery_periodic_task(115)

    s.pause!(true, "manual")

    s.reload

    assert s.pause_state == "manual"
  end

  test "pause - with pause, unpause should reset pause_state" do
    s = Scheduler.last
    s.updated_by_user_id = User.last.id
    s.grafana_dashboard_id = "9"
    s.save!

    mock_grafana_dashboard_alerts(s, 200, response: '[{"id": 55}]')
    mock_grafana_dashboard_alert_pause(55, 200, response: '{}', should_pause: true)
    mock_grafana_dashboard_alert_pause(55, 200, response: '{}', should_pause: false)
    mock_find_celery_periodic_task(s.id, 200, '{"id": 115}')
    mock_disable_celery_periodic_task(115)
    mock_enable_celery_periodic_task(115)

    s.pause!(true, "manual")

    s.reload

    assert s.pause_state == "manual"

    # then unpause should remove the pause state

    s.unpause!

    s.reload

    assert s.pause_state == ""
  end

  test "unpause - happy path" do
    s = Scheduler.last
    s.updated_by_user_id = User.last.id
    s.grafana_dashboard_id = "9"
    s.save!

    mock_grafana_dashboard_alerts(s, 200, response: '[{"id": 56}]')
    mock_grafana_dashboard_alert_pause(56, 200, response: '{}', should_pause: false)
    mock_find_celery_periodic_task(s.id, 200, '{"id": 115}')
    mock_enable_celery_periodic_task(115)

    s.unpause!
  end

  test "on delete, should delete in grafana and scheduler resources" do
    p = Project.last

    sched = SchedulerSocketPing.create!(
      project: p, schedule: "* * * * *", name: 's', updated_by_user_id: User.last.id
    )

    sched.params = { "name" => "test", "port" => 80, "host" => "localhost" }
    sched.save!

    assert sched.errors.count == 0
    assert sched.resources.count == 1
    resource = sched.resources.first

    mock_find_celery_periodic_task(sched.id, 200)
    mock_delete_celery_periodic_task(sched.id)
    mock_get_grafana_dashboard_by_uid(sched.id, 200, response: '{}')
    mock_delete_grafana_dashboard(sched, 200)

    sched.destroy

    resource = Resource.find_by id: resource.id

    assert ! resource
  end
end
