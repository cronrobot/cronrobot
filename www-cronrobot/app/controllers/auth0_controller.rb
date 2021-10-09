
class Auth0Controller < ApplicationController
  skip_before_action :verify_authenticity_token, only: :callback

  def callback
    # OmniAuth stores the informatin returned from Auth0 and the IdP in request.env['omniauth.auth'].
    # In this code, you will pull the raw_info supplied from the id_token and assign it to the session.
    # Refer to https://github.com/auth0/omniauth-auth0#authentication-hash for complete information on 'omniauth.auth' contents.
    auth_info = request.env['omniauth.auth']

    session[:userinfo] = auth_info['extra']['raw_info']

    email = session[:userinfo]["email"]
    uid = session[:userinfo]["sub"]

    create_grafana_user(uid, email)

    # Redirect to the URL you want after successful auth
    redirect_to '/dashboard'
  end

  def failure
    # Handles failed authentication -- Show a failure page (you can also handle with a redirect)
    @error_msg = request.params['message']

    error_msg = request.env['omniauth.error']
    error_type = request.env['omniauth.error.type']

    # It's up to you what you want to do with the error information
    # You could display it to the user or log it somehow.
    Rails.logger.debug("Auth0 Error: #{error_msg}. Error Type: #{error_type}")
  end

  def logout
    reset_session
    redirect_to logout_url
  end

  def create_grafana_user(uid, email, opts = {})
    unless User.exists?(uid: uid)
      grafana_body = {
        "name" => email,
        "email" => email,
        "login" => email,
        "password" => opts[:pw] || User.random_password,
        "OrgId": 1
      }

      result = JSON.parse(Grafana.post("/admin/users", grafana_body).body)

      User.create!(
        uid: uid,
        grafana_password: grafana_body["password"],
        grafana_user_id: result["id"]
      )
    end
  end

  private
  AUTH0_CONFIG = Rails.application.config_for(:auth0)

  def logout_url
    request_params = {
      returnTo: root_url,
      client_id: AUTH0_CONFIG['auth0_client_id']
    }

    URI::HTTPS.build(host: AUTH0_CONFIG['auth0_domain'], path: '/v2/logout', query: to_query(request_params)).to_s
  end

  def to_query(hash)
    hash.map { |k, v| "#{k}=#{CGI.escape(v)}" unless v.nil? }.reject(&:nil?).join('&')
  end
end