require "test_helper"

class ResourceSchedulerSocketPingTest < ActiveSupport::TestCase
  test "Create with proper scheduler" do
    p = Project.last

    sched = SchedulerSocketPing.create!(
      project: p, schedule: "* * * * *", name: 's', updated_by_user_id: User.last.id
    )

    params = {"port" => "1234", "host" => "localhost"}
    resource = ResourceSchedulerSocketPing.create!(reference_id: sched.id, params: params)

    assert resource
    assert sched.resources.count == 1
    assert sched.resources.first == resource
    assert resource.params["port"] == 1234
  end

  test "Create with wrong scheduler" do
    p = Project.last

    sched = Scheduler.create!(
      project: p, schedule: "* * * * *", name: 's', updated_by_user_id: User.last.id
    )

    params = {"port" => 1234, "host" => "localhost"}
    resource = ResourceSchedulerSocketPing.create(reference_id: sched.id, params: params)

    assert_equal resource.valid?, false
  end
end
