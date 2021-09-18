module DashboardHelper
  
  def section_active(param_name)
    @section == param_name ? "active" : ""
  end
end
