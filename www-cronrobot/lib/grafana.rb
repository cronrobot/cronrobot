
class Grafana
  def self.api_url(path)
    base_url = Rails.application.credentials.dig(:grafana, :api_base_url)

    "#{base_url}#{path}"
  end

  def self.base_url(path)
    base_url = Rails.application.credentials.dig(:grafana, :base_url)

    "#{base_url}#{path}"
  end

  def self.get(path, headers = {})
    Rails.logger.info("Grafana GET #{path}")
    HTTParty.get(Grafana.api_url(path), headers: headers)
  end

  def self.delete(path, headers = {})
    Rails.logger.info("Grafana DELETE #{path}")
    HTTParty.delete(Grafana.api_url(path), headers: headers)
  end

  def self.post(path, body, headers = {})
    Rails.logger.info("Grafana POST #{path}")

    HTTParty.post(
      Grafana.api_url(path),
      body: body,
      headers: headers#,
      # debug_output: $stdout
    )
  end

  def self.headers()
    headers = {
      "Content-Type" => "application/json",
      "Accept" => "application/json"
    }
  end

  def self.dashboard_url(model)
    Grafana.base_url("/d/#{model.id}/")
  end

  def self.dashboard_exists?(model)
    result_get = Grafana.get("/dashboards/uid/#{model.id}", Grafana.headers)

    result_get.code == 200 ? JSON.parse(result_get.body) : nil
  end

  def self.update_dashboard_permissions(model, users)
    dashboard = Grafana.dashboard_exists?(model)
    grafana_editor_permission_id = 2

    if !dashboard || !dashboard.dig("dashboard", "id")
      Rails.logger.debug("Skipping dashboard permissions update")
      return
    end

    dashboard_id = dashboard["dashboard"]["id"]

    Rails.logger.debug("Permissions Dashboard id #{dashboard_id}")

    permissions = users.map do |user|
      {
        "userId" => user.grafana_user_id.to_i,
        "permission" => grafana_editor_permission_id
      }
    end

    body = { "items" =>  permissions }

    Grafana.post("/dashboards/id/#{dashboard_id}/permissions", body.to_json, Grafana.headers)
  end

  def self.destroy_dashboard(model)
    result_get = Grafana.delete("/dashboards/uid/#{model.id}", Grafana.headers)


    result_get.code == 200
  end

  def self.upsert_dashboard(model)
    existing_dashboard = Grafana.dashboard_exists?(model)
    engine = GrafanaTemplateEngine.new(model)

    if existing_dashboard.present?
      # update
      Rails.logger.info("Will update dashboard #{existing_dashboard["id"]}")
      engine = GrafanaTemplateEngine.new(model, model_internal_id: existing_dashboard["id"])
    end

    grafana_dashboard_to_update = JSON.parse(engine.render)
    Rails.logger.debug("Dashboard update: #{JSON.pretty_generate(grafana_dashboard_to_update)}")

    Grafana.post(
      "/dashboards/db",
      grafana_dashboard_to_update.to_json,
      Grafana.headers
    )
  end
end
