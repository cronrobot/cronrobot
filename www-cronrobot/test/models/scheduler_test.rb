require "test_helper"

class SchedulerTest < ActiveSupport::TestCase
  test "Create" do
    p = Project.last

    sched = Scheduler.create!(
      project: p,
      schedule: "* * * * *",
      name: 's',
      notification_channels: ["", "12"],
      updated_by_user_id: User.last.id
      )

    assert sched
    assert sched.notification_channels == ["12"]
  end

  test "Create - with resource id" do
    p = Project.last

    user = User.last

    resource = ResourceProjectSsh.create!(
      project: p,
      type: "ResourceProject",
      params: {
        param1: 123, host: "localhost", username: "user", private_key: "private_key"
      }
    )

    s = Scheduler.last
    s.project_id = p.id
    s.updated_by_user_id = user.id
    s.save!

    p.user = user
    p.save!

    resources = Resource.accessible_by(user)

    sched = Scheduler.create(
      project: p,
      schedule: "* * * * *",
      name: 's',
      notification_channels: ["", "12"],
      updated_by_user_id: user.id,
      params: { "resource_id" => resources.last.id }
      )

    assert sched.valid?
  end

  test "Create - with unauthorized resource id should fail" do
    p = Project.last

    user = User.last

    resources = Resource.accessible_by(user)

    assert resources.count.zero?

    assert_raises User::AuthorizationError do
      Scheduler.create(
        project: p,
        schedule: "* * * * *",
        name: 's',
        notification_channels: ["", "12"],
        updated_by_user_id: user.id,
        params: { "resource_id" => Resource.last.id }
      )
    end
  end
end
