
require 'test_helper'
require 'test_api_helper'

class Api::TestController < ApiController

  def index
    render :json => {}
  end

end