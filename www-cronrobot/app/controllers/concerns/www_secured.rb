module WwwSecured
  extend ActiveSupport::Concern

  included do
    before_action :verify_authentication
  end

  def retrieve_authenticated_user(user_uid)
    auth_scheme = ENV["AUTH_SCHEME"] || "bypass"

    if auth_scheme == "bypass"
      current_user = User.find_by(uid: "admin")

      unless current_user
        current_user = User.create!(uid: "admin", grafana_user_id: "-")
      end

      current_user
    else
      User.find_by(uid: user_uid)
    end
  end

  def verify_authentication
    session_user = Rails.env.test? ? params["userinfo"] : session[:userinfo]

    if requires_auth
      @current_user = retrieve_authenticated_user(session_user&.dig("sub"))
      redirect_to '/' if @current_user.blank?
    end
  end
end