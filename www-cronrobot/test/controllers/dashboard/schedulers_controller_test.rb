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

end
