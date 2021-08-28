require "test_helper"

class SchedulerHttpControllerTest < ActionDispatch::IntegrationTest
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
      "scheduler_http" => {
        "project_id" => "#{project.id}",
        "name" => "sockping",
        "schedule" => "* * * * *",
        "params" => { "url" => "http://url.com/" }
      }
    }
    post '/dashboard/scheduler_https', params: body, as: :json

    assert response.parsed_body.include?("redirected")
  end

end
