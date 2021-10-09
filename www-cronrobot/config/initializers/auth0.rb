# ./config/initializers/auth0.rb
AUTH0_CONFIG = Rails.application.config_for(:auth0)

Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :auth0,
    AUTH0_CONFIG['auth0_client_id'],
    AUTH0_CONFIG['auth0_client_secret'],
    AUTH0_CONFIG['auth0_domain'],
    callback_path: '/auth/auth0/callback',
    authorize_params: {
      scope: 'openid profile email'
    }
  )
end

OmniAuth.config.full_host = lambda do |env|

  scheme         = env['rack.url_scheme']
  local_host     = env['HTTP_HOST']
  forwarded_host = env['HTTP_X_FORWARDED_HOST']

  Rails.logger.info "scheme #{scheme.inspect}"
  Rails.logger.info "forwarded_host #{forwarded_host.inspect}"
  Rails.logger.info "local_host #{local_host.inspect}"

  host = forwarded_host.blank? ? "#{scheme}://#{local_host}" : "#{scheme}://#{forwarded_host}"

  Rails.logger.info "full_host = #{host}"

  host
end