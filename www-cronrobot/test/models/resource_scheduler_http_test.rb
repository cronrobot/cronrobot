require "test_helper"

class ResourceSchedulerHttpTest < ActiveSupport::TestCase
  test "Create with proper scheduler" do
    p = Project.last

    sched = SchedulerHttp.create!(
      project: p, schedule: "* * * * *", name: 's', updated_by_user_id: User.last.id
    )

    params = {"url" => "http://url.com/"}
    resource = ResourceSchedulerHttp.create!(reference_id: sched.id, params: params)

    assert resource
    assert sched.resources.count == 1
    assert sched.resources.first == resource
    assert resource.params["url"] == "http://url.com/"
  end

  test "Create with wrong scheduler" do
    p = Project.last

    sched = Scheduler.create!(
      project: p, schedule: "* * * * *", name: 's', updated_by_user_id: User.last.id
    )

    params = {}
    resource = ResourceSchedulerHttp.create(reference_id: sched.id, params: params)

    assert_equal resource.valid?, false
  end
end
