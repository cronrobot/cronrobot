require "test_helper"

class Auth0ControllerTest < ActionDispatch::IntegrationTest
  test "grafana user create if does not exists" do
    cntrl = Auth0Controller.new

    pw = "oFWD4JR0Nn"
    mock_create_grafana_admin_create_user(200, pw: pw)
    cntrl.create_grafana_user("123456", "test@mail.com", pw: pw)
    
    user = User.find_by!(uid: "123456")

    assert user
    assert user.uid == "123456"
    assert user.grafana_password == pw
    assert user.grafana_user_id == "10"
  end

  test "grafana should not create user if already exists" do
    cntrl = Auth0Controller.new

    pw = "oFWD4JR0Nn"
    
    User.create!(uid: "123456", grafana_password: "asdfffff", grafana_user_id: "12")

    cntrl.create_grafana_user("123456", "test@mail.com", pw: pw)
    
    user = User.find_by!(uid: "123456")

    assert user
    assert user.uid == "123456"
  end
end
