require "test_helper"

class GrafanaTemplateEngineTest < ActiveSupport::TestCase
  test "happy path, scheduler socket ping" do
    p = Project.last
    sched = SchedulerSocketPing.create!(schedule: '* * * * *', project: p)

    engine = GrafanaTemplateEngine.new(sched)

    content = engine.render
    
    assert content.include?("\"uid\": \"#{sched.id}\"")
    assert content.include?("(ID: #{sched.id})")
  end
end
