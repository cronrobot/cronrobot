require 'test_helper'
require 'test_api_helper'

class TestControllerTest < ActionDispatch::IntegrationTest

  test '/api/test' do
    get '/api/test',
      headers: api_headers,
      as: :json

    assert_equal response.parsed_body, {}
    assert_response :success
  end

  test '/api/test without token' do
    get '/api/test',
      headers: {},
      as: :json

    assert_response :unauthorized
  end
end
