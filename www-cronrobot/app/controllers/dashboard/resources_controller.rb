
class Dashboard::ResourcesController < DashboardController

  def set_current_section
    @section = "resource"
  end

  def index
    @resources = Resource.accessible_by(@current_user)
      .select { |r| r.type == "ResourceProject" }
  end

  def new
    @resource = Resource.new
    @resource.reference_id = @project.id
  end

  def create
    ch = Resource.create!(
      allowed_resource_params.merge(
        "type" => "ResourceProject", "reference_id" => @project.id
      )
    )

    flash[:success] = "Resource successfully saved!"
    redirect_to action: :update, id: ch.id
  end

  def update
    @resource = find_resource(params["id"])
    new_params = allowed_resource_params

    if new_params["params"].dig("private_key").blank?
      new_params["params"]["private_key"] = @resource.params["private_key"]
    end

    @resource.update!(new_params)

    redirect_to action: :index
  end

  def destroy
    @resource = find_resource(params["id"])
    @resource.destroy!

    redirect_to action: :index
  end

  def show
    @resource = find_resource(params["id"])
  end

  private

  def find_resource(id)
    Resource.accessible_by(@current_user).find { |r| "#{r.id}" == "#{id}" }
  end

  def allowed_resource_params
    params_permit(
      (params.require(:resource) rescue nil) || (params.require(:resource_project) rescue nil)
    )
  end

  def params_permit(given_params)
    given_params.permit(:reference_id, :sub_type, params: {})
  end
end
