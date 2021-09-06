require "test_helper"

class ResourceProjectTest < ActiveSupport::TestCase
  test "Create with proper scheduler" do
    p = Project.last
    p.user_id = User.last.id
    p.save!


    params = {
      "host" => "localhost",
      "username": "ubuntu",
      "port": 22,
      "private_key": "--"
    }

    resource = ResourceProjectSsh.create!(
      reference_id: p.id, type: "ResourceProject", params: params
    )

    sched = SchedulerSsh.create!(
      project: p, schedule: "* * * * *", name: 's', updated_by_user_id: User.last.id,
      params: { "resource_id" => resource.id }
    )

    sched.reload

    assert_raises Exception do
      resource.destroy!
    end

  end

  test "changing resource project should repopulate store params" do
    p = Project.last
    p.user_id = User.last.id
    p.save!


    params = {
      "host" => "localhost",
      "username": "ubuntu",
      "port": 22,
      "private_key": "--"
    }

    resource = ResourceProjectSsh.create!(
      reference_id: p.id, type: "ResourceProject", params: params
    )

    sched = SchedulerSsh.create!(
      project: p, schedule: "* * * * *", name: 's', updated_by_user_id: User.last.id,
      params: { "resource_id" => resource.id }
    )

    sched_resource = sched.resources.first
    sched.reload

    sched_resource.params["command"] = "ls -la"
    sched_resource.save!
    
    assert sched_resource.params["private_key"] == "--"
    assert sched_resource.params["port"] == 22

    # changing the project resource should repopulate the scheduler resource
    resource.params["private_key"] = "--key"
    resource.params["port"] = 22222
    resource.save!

    sched_resource.reload
    assert sched_resource.params["private_key"] == "--key"
    assert sched_resource.params["port"] == 22222
    assert sched_resource.params["command"] == "ls -la"

  end
end