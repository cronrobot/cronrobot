ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

require 'webmock/minitest'

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  def mock_find_celery_periodic_task(id, status_code = 200, response_body="")
    stub_request(:get,
      "http://localhost:8000/api/periodic-tasks/find?name=scheduler-#{id}").
    with(
      headers: {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'User-Agent'=>'Ruby'
      }).
    to_return(status: status_code, body: response_body, headers: {})
  end

  def mock_disable_celery_periodic_task(id, status_code = 200, response_body="")
    stub_request(:post, "http://localhost:8000/api/periodic-tasks/#{id}/disable").
    with(
      body: "{}",
      headers: {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'User-Agent'=>'Ruby'
      }).
    to_return(status: 200, body: response_body, headers: {})
  end

  def mock_enable_celery_periodic_task(id, status_code = 200, response_body="")
    stub_request(:post, "http://localhost:8000/api/periodic-tasks/#{id}/enable").
    with(
      body: "{}",
      headers: {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'User-Agent'=>'Ruby'
      }).
    to_return(status: 200, body: response_body, headers: {})
  end

  def mock_delete_celery_periodic_task(id, status_code = 200)
    stub_request(:delete, "http://localhost:8000/api/periodic-tasks/scheduler-#{id}/").
    with(
      headers: {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'User-Agent'=>'Ruby'
      }).
    to_return(status: 200, body: "", headers: {})
  end

  def mock_create_celery_periodic_task(status_code = 200, opts = {})
    id = opts[:id]
    task = opts[:task]
    schedule = opts[:schedule]

    stub_request(:post, "http://localhost:8000/api/periodic-tasks/").
    with(
      body: "name=scheduler-#{id}&task=#{task}&schedule=#{schedule}" +
        "&scheduler_id=#{id}&resource_id=",
      headers: {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'User-Agent'=>'Ruby'
      }).
    to_return(status: status_code, body: "", headers: {})
  end

  ## grafana

  def mock_create_grafana_admin_create_user(status_code = 200, opts = {})
    stub_request(:post, "http://grafana.cronrobot.io/api/admin/users").
    with(
      body: "name=test%40mail.com&email=test%40mail.com&login=test%40mail.com&password=#{opts[:pw]}&OrgId=1",
      headers: {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Authorization'=>'Basic YWRtaW46U2lzaWJvaXJlMQ==',
      'User-Agent'=>'Ruby'
      }).
    to_return(status: 200, body: '{"id": 10}', headers: {})
  end

  
  def mock_get_grafana_dashboard_by_uid(uid, status_code = 200, opts = {})
    stub_request(:get, "http://grafana.cronrobot.io/api/dashboards/uid/#{uid}").
    with(
      headers: {
      'Accept'=>'application/json',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Authorization'=>'Basic YWRtaW46U2lzaWJvaXJlMQ==',
      'Content-Type'=>'application/json',
      'User-Agent'=>'Ruby'
      }).
    to_return(status: status_code, body: opts[:response], headers: {})
  end

  def mock_delete_grafana_dashboard(scheduler, status_code = 200, opts = {})
    stub_request(:delete, "http://grafana.cronrobot.io/api/dashboards/uid/#{scheduler.id}").
    with(
      headers: {
      'Accept'=>'application/json',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Authorization'=>'Basic YWRtaW46U2lzaWJvaXJlMQ==',
      'Content-Type'=>'application/json',
      'User-Agent'=>'Ruby'
      }).
    to_return(status: status_code, body: "{}", headers: {})
  end

  def mock_create_grafana_dashboard(scheduler, status_code = 200, opts = {})
    stub_request(:post, "http://grafana.cronrobot.io/api/dashboards/db").
    with(
      body: opts[:request_body],
      headers: {
      'Accept'=>'application/json',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Authorization'=>'Basic YWRtaW46U2lzaWJvaXJlMQ==',
      'Content-Type'=>'application/json',
      'User-Agent'=>'Ruby'
      }).
    to_return(status: status_code, body: opts[:response], headers: {})
  end

  def mock_grafana_dashboard_alerts(scheduler, status_code = 200, opts = {})
    stub_request(:get,
      "http://grafana.cronrobot.io/api/alerts?dashboardId=#{scheduler.grafana_dashboard_id}").
    with(
      headers: {
      'Accept'=>'application/json',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Authorization'=>'Basic YWRtaW46U2lzaWJvaXJlMQ==',
      'Content-Type'=>'application/json',
      'User-Agent'=>'Ruby'
      }).
    to_return(status: status_code, body: opts[:response], headers: {})
  end

  def mock_grafana_dashboard_alert_pause(alert_id, status_code = 200, opts = {})
    should_pause = opts[:should_pause]

    stub_request(:post,
      "http://grafana.cronrobot.io/api/alerts/#{alert_id}/pause").
    with(
      body: "{\"paused\":#{should_pause}}",
      headers: {
      'Accept'=>'application/json',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Authorization'=>'Basic YWRtaW46U2lzaWJvaXJlMQ==',
      'Content-Type'=>'application/json',
      'User-Agent'=>'Ruby'
      }).
    to_return(status: 200, body: opts[:response], headers: {})
  end

  def mock_update_grafana_dashboard_permissions(scheduler, status_code = 200, opts = {})
    dashboard_id = opts[:dashboard_id]

    stub_request(:post, "http://grafana.cronrobot.io/api/dashboards/id/#{dashboard_id}/permissions").
    with(
      body: "{\"items\":[{\"userId\":9,\"permission\":2}]}",
      headers: {
      'Accept'=>'application/json',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Authorization'=>'Basic YWRtaW46U2lzaWJvaXJlMQ==',
      'Content-Type'=>'application/json',
      'User-Agent'=>'Ruby'
      }).
    to_return(status: status_code, body: "{}", headers: {})
  end

  ## notification channels

  def mock_get_grafana_notification_channel(ch, status_code = 200)
    stub_request(:get, "http://grafana.cronrobot.io/api/alert-notifications/uid/#{ch.id}").
    with(
      headers: {
      'Accept'=>'application/json',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Authorization'=>'Basic YWRtaW46U2lzaWJvaXJlMQ==',
      'Content-Type'=>'application/json',
      'User-Agent'=>'Ruby'
      }).
    to_return(status: status_code, body: "{}", headers: {})
  end

  def mock_update_grafana_notification_channel(ch, status_code = 200, request_body = "")
    stub_request(:post, "http://grafana.cronrobot.io/api/alert-notifications").
    with(
      body: request_body,
      headers: {
      'Accept'=>'application/json',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Authorization'=>'Basic YWRtaW46U2lzaWJvaXJlMQ==',
      'Content-Type'=>'application/json',
      'User-Agent'=>'Ruby'
      }).
    to_return(status: status_code, body: "{}", headers: {})
  end

  def mock_delete_grafana_notification_channel(ch, status_code=200)
    stub_request(:delete, "http://grafana.cronrobot.io/api/alert-notifications/uid/#{ch.id}").
    with(
      headers: {
      'Accept'=>'application/json',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Authorization'=>'Basic YWRtaW46U2lzaWJvaXJlMQ==',
      'Content-Type'=>'application/json',
      'User-Agent'=>'Ruby'
      }).
    to_return(status: status_code, body: "{}", headers: {})
  end

  # Add more helper methods to be used by all tests here...
end
