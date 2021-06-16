
class Api::ResourceController < ApiController

  def retrieve
    # should be USER based if users are authorized to request that in the future    
    
    resource = Resource.find(params[:id])

    render :json => resource
  end

end