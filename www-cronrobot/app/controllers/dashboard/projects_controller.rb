class Dashboard::ProjectsController < DashboardController

  def index
    @projects = @current_user.projects
  end

  def show
    @updated_project = current_project
  end

  def update
    project = current_project
    project.update!(allowed_params)

    flash[:success] = "Project updated successfully!"
    redirect_to_project(project.id)
  end

  def new

    @updated_project = Project.new

  end

  def create
    project = Project.create!(allowed_params.merge(user_id: @current_user.id))

    flash[:success] = "Project created successfully!"
    redirect_to_project(project.id)
  end

  def destroy

    project = current_project
    project.destroy!

    flash[:success] = "Project successfully removed!"
    redirect_to controller: :projects, action: :index
  end

  protected

  def redirect_to_project(project_id)
    redirect_to controller: :schedulers, action: :index, selected_project_id: project_id
  end

  def current_project
    @current_user.projects.find { |p| p.id == params["id"].to_i }
  end

  def allowed_params
    params.require(:project).permit(:name)
  end

  def set_current_section
    @section = "project"
  end

end