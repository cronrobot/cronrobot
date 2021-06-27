class DashboardController < ApplicationController
  layout "dashboard"
  include WwwSecured
  
  before_action :ensure_project_selected

  private

  def ensure_project_selected
    project = @current_user.projects.first

    unless project
      project = @current_user.projects.create!(name: "Default")
    end

    obj_session = Rails.env.test? ? params : session

    obj_session["selected_project_id"] ||= project.id

    unless Project.exists?(id: obj_session["selected_project_id"])
      obj_session["selected_project_id"] = project.id
    end

    @project = Project.find_by id: obj_session["selected_project_id"]
  end

end