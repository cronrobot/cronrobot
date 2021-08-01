class ApiController < ApplicationController
  include Secured
  
  protected

  def disable_json_escaping
    ActiveSupport.escape_html_entities_in_json = false
  end

end