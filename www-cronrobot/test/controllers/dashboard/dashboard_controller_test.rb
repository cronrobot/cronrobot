require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest

  setup do
    set_auth0
  end

  test "not authorized access project" do
    current_user = User.last
    current_user.uid = "1234"
    current_user.save!
    project = Project.last

    body = {
      "userinfo" => {
        "sub" => "1234"
      },
      "selected_project_id": project.id
    }
    scheduler = Scheduler.last

    get "/dashboard/support/", params: body

    assert_response :found
  end

  test "with bypass should work without auth" do
    ENV["AUTH_SCHEME"] = "bypass"

    current_user = User.last
    current_user.uid = "1234"
    current_user.save!
    project = Project.last

    body = {}
    scheduler = Scheduler.last

    get "/dashboard/support/", params: body

    assert_response :ok
  end

  test "authorized access project" do
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
      "selected_project_id": project.id
    }
    scheduler = Scheduler.last

    get "/dashboard/support/", params: body

    assert_response :ok
  end
end
