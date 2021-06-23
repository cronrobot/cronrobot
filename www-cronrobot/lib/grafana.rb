
class Grafana
  def self.api_url(path)
    base_url = Rails.application.credentials.dig(:grafana, :api_base_url)

    "#{base_url}#{path}"
  end

  def self.get(path, headers = {})
    Rails.logger.info("Grafana GET #{path}")
    HTTParty.get(Grafana.api_url(path), headers: headers)
  end

  def self.post(path, body, headers = {})
    HTTParty.post(
      Grafana.api_url(path),
      body: body,
      headers: headers#,
      #debug_output: $stdout
    )
  end

  def self.upsert_dashboard(model)
    headers = {
      "Content-Type" => "application/json",
      "Accept" => "application/json"
    }

    result_get = Grafana.get("/dashboards/uid/#{model.id}", headers)
    engine = GrafanaTemplateEngine.new(model)

    if result_get.code == 200
      # update
      existing_dashboard = JSON.parse(result_get.body)
      engine = GrafanaTemplateEngine.new(model, model_internal_id: existing_dashboard["id"])
    end

    grafana_dashboard_to_update = JSON.parse(engine.render)

    Grafana.post(
      "/dashboards/db",
      grafana_dashboard_to_update.to_json,
      headers
    )
  end
end
