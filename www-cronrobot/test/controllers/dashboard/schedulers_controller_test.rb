require "test_helper"

class SchedulersControllerTest < ActionDispatch::IntegrationTest

  setup do
    set_auth0
  end

  test "pause" do
    current_user = User.last
    current_user.uid = "1234"
    current_user.save!
    project = Project.last

    project.user = current_user
    project.save!

    body = {
      "userinfo" => {
        "sub" => "1234"
      },
    }
    scheduler = Scheduler.last

    mock_grafana_dashboard_alerts(scheduler, 200, response: '[{"id": 55}]')
    mock_grafana_dashboard_alert_pause(55, 200, response: '{}', should_pause: true)
    mock_find_celery_periodic_task(scheduler.id, 200, '{"id": 115}')
    mock_disable_celery_periodic_task(115)

    post "/dashboard/schedulers/#{scheduler.id}/pause", params: body, as: :json

    assert response.parsed_body.include?("redirected")

    scheduler.reload
    assert scheduler.pause_state == "manual"
  end

  test "unpause" do
    current_user = User.last
    current_user.uid = "1234"
    current_user.save!
    project = Project.last

    project.user = current_user
    project.save!

    body = {
      "userinfo" => {
        "sub" => "1234"
      },
    }
    scheduler = Scheduler.last

    mock_grafana_dashboard_alerts(scheduler, 200, response: '[{"id": 55}]')
    mock_grafana_dashboard_alert_pause(55, 200, response: '{}', should_pause: true)
    mock_grafana_dashboard_alert_pause(55, 200, response: '{}', should_pause: false)
    mock_find_celery_periodic_task(scheduler.id, 200, '{"id": 115}')
    mock_enable_celery_periodic_task(115)

    post "/dashboard/schedulers/#{scheduler.id}/unpause", params: body, as: :json

    assert response.parsed_body.include?("redirected")

    scheduler.reload
    assert scheduler.pause_state == ""
  end

  test "access scheduler, with notification channel" do
    default_user_project

    assert @current_user.notification_channels.count.positive?

    body = default_user_body
    scheduler = SchedulerHttp.create!(
      project: @project, schedule: "* * * * *", name: 's', updated_by_user_id: @current_user.id
    )

    get "/dashboard/scheduler_https/#{scheduler.id}", params: body

    assert response.parsed_body.include?("Hold Shift to select multiple channels")
  end

  test "access scheduler, without notification channel" do
    default_user_project
    
    p2 = Project.where.not(id: @project.id).first
    @current_user.notification_channels.update_all(project_id: p2.id)

    assert !@current_user.notification_channels.count.positive?

    body = default_user_body
    scheduler = SchedulerHttp.create!(
      project: @project, schedule: "* * * * *", name: 's', updated_by_user_id: @current_user.id
    )

    get "/dashboard/scheduler_https/#{scheduler.id}", params: body

    assert response.parsed_body.include?("There is currently no notification channel")
  end

end
