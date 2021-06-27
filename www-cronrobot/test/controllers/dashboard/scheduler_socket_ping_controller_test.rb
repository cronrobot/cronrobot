require "test_helper"

class SchedulerSocketPingControllerTest < ActionDispatch::IntegrationTest
  test "post" do
    current_user = User.last
    current_user.uid = "1234"
    current_user.save!
    body = {
      "selected_project_id" => "#{Project.last.id}",
      "userinfo" => {
        "sub" => "1234"
      },
      "scheduler_socket_ping" => {
        "project_id" => "#{Project.last.id}",
        "name" => "sockping",
        "schedule" => "* * * * *",
        "params" => { "port" => 1234, "host" => "localhost"}
      }
    }
    post '/dashboard/scheduler_socket_pings', params: body, as: :json

    assert response.parsed_body.include?("redirected")
  end

end
