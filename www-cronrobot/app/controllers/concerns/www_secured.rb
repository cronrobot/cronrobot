module WwwSecured
  extend ActiveSupport::Concern

  included do
    before_action :logged_in_using_omniauth?
  end

  def logged_in_using_omniauth?
    session_user = Rails.env.test? ? params["userinfo"] : session[:userinfo]
    @current_user = User.find_by(uid: session_user&.dig("sub"))
    redirect_to '/' if session_user.blank? || @current_user.blank?
  end
end