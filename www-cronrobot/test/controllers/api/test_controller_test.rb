require 'test_helper'
require 'test_api_helper'

class TestControllerTest < ActionDispatch::IntegrationTest

  setup do
    WebMock.allow_net_connect!
  end

  test '/api/test' do
    get '/api/test',
      headers: api_headers,
      as: :json

    assert_equal response.parsed_body, {}
  end
end
