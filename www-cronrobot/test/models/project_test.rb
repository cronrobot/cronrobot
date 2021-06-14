require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  test "create" do
    p = Project.create!(name: "myproject")

    assert p
  end
end
