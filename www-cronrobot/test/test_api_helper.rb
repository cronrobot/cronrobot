
class ActiveSupport::TestCase

  def api_headers
    client_id = "5643f9b0-c3af-4ec2-8b92-146f9652fdbc"
    token = AuthToken.find_by client_id: client_id

    unless token
      token = AuthToken.create!(client_id: client_id)
    end

    {
      "x-auth-client-id" => token.client_id,
      "x-auth-client-secret" => token.client_secret
    }
  end

end
