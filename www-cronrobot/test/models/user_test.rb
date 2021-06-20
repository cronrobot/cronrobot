require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "random_password" do
    pw = User.random_password(10).length
    assert pw == 10
  end
end
