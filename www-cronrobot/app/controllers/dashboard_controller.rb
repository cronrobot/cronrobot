class DashboardController < ApplicationController
  layout "dashboard"
  include WwwSecured
  include DashboardExceptionHandler
  
  before_action :ensure_project_selected
  before_action :populate_accessible_projects
  before_action :set_current_section

  def requires_auth
    true
  end

  private

  def set_current_section
  end

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

  def populate_accessible_projects

    list_projects = @current_user.projects - [@project]

    @accessible_projects = [@project] + list_projects
  end

end