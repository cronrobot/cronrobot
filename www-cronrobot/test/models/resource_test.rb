require "test_helper"

class ResourceTest < ActiveSupport::TestCase
  test "create project resource" do
    project = Project.last

    resource = project.resources.create!(params: {param1: 123, param2: 456})

    assert resource.class == ResourceProject
    assert resource.project == project
    assert resource.params["param1"] == 123
    assert resource.params["param2"] == 456
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
