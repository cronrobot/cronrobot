
class GrafanaTemplateEngine
  include ERB::Util

  def initialize(model, opts = {})
    @model = model
    @opts = opts
  end

  def render()
    template_name = @model.default_grafana_template
    template = File.read(
      Rails.root.join("lib", "grafana_templates/#{template_name}.rjson")
    )
    
    ERB.new(template).result(binding)
  end
end
