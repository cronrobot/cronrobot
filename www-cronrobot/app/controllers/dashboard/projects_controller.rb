class Dashboard::ProjectsController < DashboardController

  def new

    @project = Project.new

  end

  def create

    flash[:success] = "Project created successfully!"
    redirect_to controller: :home, action: :index
  end

end