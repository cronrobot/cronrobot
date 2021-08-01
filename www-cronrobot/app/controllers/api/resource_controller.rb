
class Api::ResourceController < ApiController

  before_action :disable_json_escaping

  def retrieve
    # should be USER based if users are authorized to request that in the future    
    
    resource = Resource.find(params[:id])

    render :json => resource
  end

  # get '/projects/:project_id/resources/:type'
  def retrieve_project_resources
    type = params[:type]
    project_id = params[:project_id]

    variables = ResourceProject.where(reference_id: project_id)
      .and(ResourceProject.where(sub_type: type).or(ResourceProject.where(type: type)))

    render :json => variables
  end

  protected

end