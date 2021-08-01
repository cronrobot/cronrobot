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

  test '/api/projects/project_id/resources/type' do
    p = Project.last
    p2 = Project.first

    assert p != p2

    Resource.create!(
      type: "ResourceProject",
      reference_id: p2.id,
      params: {"name" => "VAR2", "value" => "v1"},
      sub_type: "ResourceProjectVariable"
    )

    resource = Resource.create!(
      type: "ResourceProject",
      reference_id: p.id,
      params: {"name" => "VAR", "value" => "v1"},
      sub_type: "ResourceProjectVariable"
    )

    get "/api/projects/#{p.id}/resources/ResourceProjectVariable",
      headers: api_headers,
      as: :json

    assert response.parsed_body.count == 1
    assert response.parsed_body[0]["params"]["name"] == "VAR"
    assert response.parsed_body[0]["params"]["value"] == "v1"
  end

  test '/api/projects/project_id/resources/type with special characters' do
    p = Project.last
    p2 = Project.first

    assert p != p2

    Resource.create!(
      type: "ResourceProject",
      reference_id: p2.id,
      params: {"name" => "VAR2", "value" => "v1"},
      sub_type: "ResourceProjectVariable"
    )

    resource = Resource.create!(
      type: "ResourceProject",
      reference_id: p.id,
      params: {"name" => "VAR && nice", "value" => "v1 && yes"},
      sub_type: "ResourceProjectVariable"
    )

    get "/api/projects/#{p.id}/resources/ResourceProjectVariable",
      headers: api_headers,
      as: :json

    puts "#{response.parsed_body.inspect}"
    assert response.parsed_body.count == 1
    assert response.parsed_body[0]["params"]["name"] == "VAR && nice"
    assert response.parsed_body[0]["params"]["value"] == "v1 && yes"
  end
end
