class DashboardController < ApplicationController
  layout "dashboard"
  include WwwSecured
  include DashboardExceptionHandler
  
  before_action :ensure_project_selected

  def requires_auth
    true
  end

  private

  def ensure_project_selected
    project = @current_user.projects.first
    
    unless project
      project = @current_user.projects.create!(name: "Default")
    end

    selected_project_id = project.id

    if params["selected_project_id"]
      selected_project_id = params["selected_project_id"]
    elsif session["selected_project_id"]
      selected_project_id = session["selected_project_id"]
    end

    unless Project.exists?(id: selected_project_id)
      selected_project_id = project.id
    end

    @project = Project.find_by id: selected_project_id
    User.can_access_project(@current_user, @project)
  end

end