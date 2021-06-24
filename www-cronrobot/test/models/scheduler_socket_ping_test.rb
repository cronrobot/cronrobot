require "test_helper"

class SchedulerSocketPingTest < ActiveSupport::TestCase
  test "Create" do
    p = Project.last

    sched = SchedulerSocketPing.create!(project: p, schedule: "* * * * *", name: 's')

    assert sched
  end

  test "update" do
    p = Project.last

    sched = SchedulerSocketPing.create!(project: p, schedule: "* * * * *", name: 's')

    mock_find_celery_periodic_task(sched.id, 404)
    mock_create_celery_periodic_task(
      200,
      id: sched.id,
      task: "celery_admin.celery.socket_ping",
      schedule: "%2A%20%2A%20%2A%20%2A%20%2A"
    )
    mock_get_grafana_dashboard_by_uid(sched.id, 404, response: '{}')
    engine = GrafanaTemplateEngine.new(sched)
    request_body = "{\"overwrite\":true,\"dashboard\":{\"annotations\":{\"list\":[{\"builtIn\":1,\"datasource\":\"-- Grafana --\",\"enable\":true,\"hide\":true,\"iconColor\":\"rgba(0, 211, 255, 1)\",\"name\":\"Annotations \\u0026 Alerts\",\"type\":\"dashboard\"}]},\"description\":\"Test test\",\"editable\":true,\"gnetId\":null,\"graphTooltip\":0,\"links\":[],\"panels\":[{\"datasource\":null,\"fieldConfig\":{\"defaults\":{\"color\":{\"fixedColor\":\"text\",\"mode\":\"thresholds\"},\"mappings\":[{\"options\":{\"0\":{\"color\":\"red\",\"index\":1,\"text\":\"DOWN\"},\"100\":{\"color\":\"green\",\"index\":0,\"text\":\"UP\"}},\"type\":\"value\"}],\"thresholds\":{\"mode\":\"percentage\",\"steps\":[{\"color\":\"transparent\",\"value\":null},{\"color\":\"red\",\"value\":100},{\"color\":\"green\",\"value\":100}]},\"unit\":\"percent\"},\"overrides\":[]},\"gridPos\":{\"h\":12,\"w\":7,\"x\":0,\"y\":0},\"id\":6,\"options\":{\"reduceOptions\":{\"calcs\":[\"mean\"],\"fields\":\"/^status_int$/\",\"values\":false},\"showThresholdLabels\":false,\"showThresholdMarkers\":true,\"text\":{}},\"pluginVersion\":\"8.0.3\",\"targets\":[{\"expr\":\"{scheduler_id=\\\"980190963\\\"}\",\"maxLines\":1,\"refId\":\"A\"}],\"title\":\"Current Status\",\"transformations\":[{\"id\":\"labelsToFields\",\"options\":{}},{\"id\":\"filterFieldsByName\",\"options\":{\"include\":{\"names\":[\"ts\",\"status_int\"]}}}],\"type\":\"gauge\"},{\"datasource\":null,\"fieldConfig\":{\"defaults\":{\"color\":{\"mode\":\"thresholds\"},\"custom\":{\"fillOpacity\":70,\"lineWidth\":2},\"mappings\":[{\"options\":{\"error\":{\"color\":\"red\",\"index\":1,\"text\":\"DOWN\"},\"success\":{\"color\":\"green\",\"index\":0,\"text\":\"UP\"}},\"type\":\"value\"}],\"thresholds\":{\"mode\":\"absolute\",\"steps\":[{\"color\":\"transparent\",\"value\":null}]}},\"overrides\":[]},\"gridPos\":{\"h\":12,\"w\":17,\"x\":7,\"y\":0},\"id\":2,\"options\":{\"alignValue\":\"left\",\"legend\":{\"displayMode\":\"list\",\"placement\":\"bottom\"},\"mergeValues\":true,\"rowHeight\":0.9,\"showValue\":\"auto\",\"tooltip\":{\"mode\":\"single\"}},\"pluginVersion\":\"8.0.0\",\"targets\":[{\"expr\":\"{scheduler_id=\\\"980190963\\\"}\",\"instant\":false,\"maxLines\":2000,\"range\":true,\"refId\":\"A\"}],\"title\":\"Status history\",\"transformations\":[{\"id\":\"labelsToFields\",\"options\":{}},{\"id\":\"filterFieldsByName\",\"options\":{\"include\":{\"names\":[\"status\",\"ts\"]}}},{\"id\":\"organize\",\"options\":{\"excludeByName\":{},\"indexByName\":{},\"renameByName\":{\"status\":\"value\",\"ts\":\"\"}}},{\"id\":\"sortBy\",\"options\":{\"fields\":{},\"sort\":[{\"field\":\"ts\"}]}}],\"type\":\"state-timeline\"},{\"datasource\":null,\"gridPos\":{\"h\":12,\"w\":24,\"x\":0,\"y\":12},\"id\":4,\"options\":{\"dedupStrategy\":\"none\",\"enableLogDetails\":true,\"showLabels\":false,\"showTime\":false,\"sortOrder\":\"Descending\",\"wrapLogMessage\":false},\"targets\":[{\"expr\":\"{scheduler_id=\\\"980190963\\\"}\",\"maxLines\":2000,\"refId\":\"A\"}],\"title\":\"Logs\",\"type\":\"logs\"}],\"refresh\":\"\",\"schemaVersion\":30,\"style\":\"dark\",\"tags\":[],\"templating\":{\"list\":[]},\"time\":{\"from\":\"now-6h\",\"to\":\"now\"},\"timepicker\":{},\"timezone\":\"\"," +
      "\"title\":\"s (ID: #{sched.id})\",\"uid\":\"#{sched.id}\"}}"
    mock_create_grafana_dashboard(sched, 200, request_body: request_body, response: '{"id": 123}')

    sched.touch!
  end

  test "update - fail if non status code 200" do
    p = Project.last

    sched = SchedulerSocketPing.create!(project: p, schedule: "* * * * *", name: 's')

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

    sched = SchedulerSocketPing.create!(project: p, schedule: "* * * * *", name: 's')

    mock_find_celery_periodic_task(sched.id, 200)
    mock_delete_celery_periodic_task(sched.id)

    mock_get_grafana_dashboard_by_uid(sched.id, 200, response: '{}')

    sched.destroy
  end
end
