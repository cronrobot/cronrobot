
module Secured
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request!
  end

  private

  def authenticate_request!
    auth_token
  rescue JWT::VerificationError, JWT::DecodeError => e
    puts e
    render json: { errors: ['Not Authenticated'] }, status: :unauthorized
  end

  def http_token
    auth_header = request.headers['Authorization'] || request.headers['Myauthorization']

    if auth_header.present?
      auth_header.split(' ').last
    end
  end

  def auth_token
    @jwt_token_handler.verify(http_token)
  end
end