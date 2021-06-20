ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

require 'webmock/minitest'

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  def mock_find_celery_periodic_task(id, status_code = 200)
    stub_request(:get,
      "http://localhost:8000/api/periodic-tasks/find?name=scheduler-#{id}").
    with(
      headers: {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'User-Agent'=>'Ruby'
      }).
    to_return(status: status_code, body: "", headers: {})
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
      body: "name=scheduler-#{id}&task=#{task}&schedule=#{schedule}&resource_id=",
      headers: {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'User-Agent'=>'Ruby'
      }).
    to_return(status: status_code, body: "", headers: {})
  end

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

  # Add more helper methods to be used by all tests here...
end
