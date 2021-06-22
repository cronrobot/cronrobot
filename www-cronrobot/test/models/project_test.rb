require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  test "create" do
    u = User.last
    p = Project.create!(name: "myproject", user: u)

    assert p
  end
end
