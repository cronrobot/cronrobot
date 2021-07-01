
module Secured
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request!
  end

  private

  def authenticate_request!
    auth_token!
  rescue User::AuthorizationError => e
    render json: { errors: ['Not Authenticated'] }, status: :unauthorized
  end

  def auth_token!
    unless request.headers['x-auth-client-id']
      raise User::AuthorizationError.new("Missing auth header")
    end

    token = AuthToken.find_by client_id: request.headers['x-auth-client-id']

    unless token
      raise User::AuthorizationError.new("Unauthorized")
    end

    unless token.client_secret == request.headers['x-auth-client-secret']
      raise User::AuthorizationError.new("Unauthorized")
    end
  end
end