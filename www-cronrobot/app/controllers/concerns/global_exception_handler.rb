module GlobalExceptionHandler
  
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError do |e|
      flash[:error] = "Error: #{e}"
      redirect_back fallback_location: root_path
    end

    rescue_from Exception do |e|
      puts "err --> #{e.inspect}"
      flash[:error] = "Error: #{e}"
      redirect_back fallback_location: root_path
    end

  end
end
