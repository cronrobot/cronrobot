require 'test_helper'

class TestControllerTest < ActionDispatch::IntegrationTest
  test '/api/test' do
    get '/api/test', headers: {}, as: :json

    assert_equal response.parsed_body, {}
  end
end
