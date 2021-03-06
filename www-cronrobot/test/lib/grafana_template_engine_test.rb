require "test_helper"

class GrafanaTemplateEngineTest < ActiveSupport::TestCase
  test "happy path, scheduler socket ping" do
    p = Project.last
    sched = SchedulerSocketPing.create!(
      schedule: '* * * * *', project: p, name: 's', updated_by_user_id: User.last.id
    )

    engine = GrafanaTemplateEngine.new(sched)

    content = engine.render
    
    assert content.include?("\"uid\": \"#{sched.id}\"")
    assert content.include?("(ID: #{sched.id})")
  end
end
