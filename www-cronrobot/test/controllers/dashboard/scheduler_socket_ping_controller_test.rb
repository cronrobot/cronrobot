require "test_helper"

class SchedulerSocketPingControllerTest < ActionDispatch::IntegrationTest

  setup do
    set_auth0
  end

  test "post" do
    project = Project.last
    project.user = User.last
    project.save!
    
    current_user = project.user
    current_user.uid = "1234"
    current_user.save!

    body = {
      "selected_project_id" => "#{project.id}",
      "userinfo" => {
        "sub" => "1234"
      },
      "scheduler_socket_ping" => {
        "project_id" => "#{project.id}",
        "name" => "sockping",
        "schedule" => "* * * * *",
        "params" => { "port" => 1234, "host" => "localhost"}
      }
    }
    post '/dashboard/scheduler_socket_pings', params: body, as: :json

    assert response.parsed_body.include?("redirected")
  end

end
