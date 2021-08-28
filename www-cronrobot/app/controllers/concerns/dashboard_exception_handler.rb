module DashboardExceptionHandler
  # provides the more graceful `included` method
  extend ActiveSupport::Concern

  included do
    
    rescue_from User::AuthorizationError do |e|
      flash[:error] = "Not authorized"
      redirect_back fallback_location: root_path
    end

  end
end
