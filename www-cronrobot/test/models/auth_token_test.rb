require "test_helper"

class AuthTokenTest < ActiveSupport::TestCase
  test "create" do
    token = AuthToken.create!
    
    assert token
    assert token.client_id.length > 0
    assert token.client_secret.length > 0
  end

  test "update" do
    token = AuthToken.create!

    client_id_orig = token.client_id
    client_secret_orig = token.client_secret

    token.created_at = Time.now
    token.save!

    token.reload

    assert client_id_orig == token.client_id
    assert client_secret_orig == token.client_secret
  end
end
