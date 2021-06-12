class ApiController < ApplicationController
  before_action :prepare_jwt_token_handler
  include Secured
  
  private

  def prepare_jwt_token_handler
    unless @jwt_token_handler
      @jwt_token_handler = JsonWebToken.new(
        tenant_url: ENV.fetch("AUTH0_API_TENANT_URL", "http://tenant_url_auth0"),
        audience: ENV.fetch("AUTH0_API_AUDIENCE", "http://auth0_api_audience")
      )
    end
  end

end