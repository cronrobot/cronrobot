
class GrafanaTemplateEngine
  include ERB::Util

  def initialize(model)
    @model = model
  end

  def render()
    template_name = @model.class.to_s
    template = File.read(
      Rails.root.join("lib", "grafana_templates/#{template_name}.rjson")
    )
    
    ERB.new(template).result(binding)
  end
end
