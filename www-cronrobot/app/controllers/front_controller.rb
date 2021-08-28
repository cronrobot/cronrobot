class FrontController < ApplicationController
  
  include WwwSecured

  def requires_auth
    false
  end
end
