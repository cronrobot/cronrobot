
class ActiveSupport::TestCase

  def api_headers
    unless @access_token
      body = {
        client_id: ENV.fetch("AUTH0_API_CLIENT_ID"),
        client_secret: ENV.fetch("AUTH0_API_CLIENT_SECRET"),
        audience: ENV.fetch("AUTH0_API_AUDIENCE"),
        grant_type: "client_credentials"
      }

      oauth_token_url = "#{ENV.fetch("AUTH0_API_TENANT_URL")}oauth/token"
      res_body = JSON.parse HTTParty.post(oauth_token_url, body: body).body

      @access_token = res_body["access_token"]
    end

    {
      Myauthorization: @access_token
    }
  end

end
