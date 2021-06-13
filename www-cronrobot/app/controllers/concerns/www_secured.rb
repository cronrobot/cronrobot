module WwwSecured
  extend ActiveSupport::Concern

  included do
    before_action :logged_in_using_omniauth?
  end

  def logged_in_using_omniauth?
    @current_user = session[:userinfo]
    redirect_to '/' unless @current_user.present?
  end
end