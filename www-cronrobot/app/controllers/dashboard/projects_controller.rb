class Dashboard::ProjectsController < DashboardController

  def new

    @updated_project = Project.new

  end

  def create
    Project.create!(allowed_params.merge(user_id: @current_user.id))

    flash[:success] = "Project created successfully!"
    redirect_to controller: :home, action: :index
  end

  protected

  def allowed_params
    params.require(:project).permit(:name)
  end

end