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
    puts "ress #{resource.inspect}"

    sched = SchedulerSsh.create!(
      project: p, schedule: "* * * * *", name: 's', updated_by_user_id: User.last.id,
      params: { "resource_id" => resource.id }
    )

    sched.reload

    assert_raises Exception do
      resource.destroy!
    end

  end
end