module DashboardHelper
  
  def section_active(param_name)
    @section == param_name ? "active" : ""
  end

  def resource_type_friendly(name)
    values = {
      "ResourceProjectVariable" => "Variable",
      "ResourceProjectSsh" => "Ssh"
    }

    values[name] || "N/A"
  end
end
