require 'test_helper'
require 'test_api_helper'

class ResourceControllerTest < ActionDispatch::IntegrationTest
  test '/api/resources/:id happy path' do
    resource = Resource.last
    resource.params = { "hello" => "world" }
    resource.save!

    get "/api/resources/#{resource.id}",
      headers: api_headers,
      as: :json

    assert_equal response.parsed_body["id"], resource.id
    assert_equal response.parsed_body["params"]["hello"], "world"
  end
end
