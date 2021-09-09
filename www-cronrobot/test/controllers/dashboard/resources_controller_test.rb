require "test_helper"

class DashboardResourcesControllerTest < ActionDispatch::IntegrationTest

  setup do
    set_auth0
  end

  test "happy path" do
    current_user = User.last
    current_user.uid = "1234"
    current_user.save!
    project = Project.last
    project.user = current_user
    project.save!

    params = {
      "host" => "localhost",
      "username": "ubuntu",
      "port": 22,
      "private_key": "--"
    }

    project_resource = ResourceProjectSsh.create!(
      reference_id: project.id, type: "ResourceProject", params: params
    )

    sched = project.schedulers.first
    sched.type = "SchedulerSocketPing"
    sched.save!

    scheduler_resource = ResourceSchedulerSocketPing.create!(
      reference_id: sched.id, params: { "port" => 22, "host" => "localhost" }
    )

    body = {
      "userinfo" => {
        "sub" => "1234"
      },
      "selected_project_id": project.id
    }
    scheduler = Scheduler.last

    get "/dashboard/resources/", params: body

    assert_response :ok
    assert_includes response.parsed_body, "resources/#{project_resource.id}"
    assert_not_includes response.parsed_body, "resources/#{scheduler_resource.id}"
  end
end
