module GlobalExceptionHandler
  
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError do |e|
      flash[:error] = "Error: #{e}"
      Rails.logger.error e.message
      Rails.logger.error e.backtrace.join "\n"
      redirect_back fallback_location: root_path
    end

    rescue_from Exception do |e|
      flash[:error] = "Error: #{e}"
      Rails.logger.error e.message
      Rails.logger.error e.backtrace.join "\n"
      redirect_back fallback_location: root_path
    end

  end
end
