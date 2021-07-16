require "test_helper"

class ResourceTest < ActiveSupport::TestCase
  test "create project ssh resource" do
    project = Project.last

    resource = ResourceProjectSsh.create!(
      project: project,
      type: "ResourceProject",
      params: {
        param1: 123, host: "localhost", username: "user", private_key: "private_key"
      }
    )

    assert resource.class == ResourceProjectSsh
    assert resource.project == project
    assert resource.params["param1"] == 123
    assert resource.params["host"] == "localhost"
    assert resource.params["private_key"] == "private_key"
    assert resource.params["username"] == "user"
    assert resource.params["port"] == 22

    assert ResourceProject.last.id == resource.id
  end

  test "create project resource ssh, missing username" do
    project = Project.last

    resource = ResourceProjectSsh.create(
      project: project,
      type: "ResourceProject",
      params: {param1: 123, host: "localhost"}
    )

    assert !resource.valid?
  end

  test "create scheduler resource" do
    scheduler = Scheduler.last

    assert scheduler

    resource = scheduler.resources.create!(params: {port: 3030, host: "localhost"})

    assert resource.class == ResourceScheduler
    assert resource.scheduler == scheduler
    assert resource.params["port"] == 3030
    assert resource.params["host"] == "localhost"
  end
end
