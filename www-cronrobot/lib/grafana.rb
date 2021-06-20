
class Grafana
  def self.api_url(path)
    base_url = Rails.application.credentials.dig(:grafana, :api_base_url)

    "#{base_url}#{path}"
  end

  def self.get(path)
    HTTParty.get(Grafana.api_url(path))
  end

  def self.post(path, body)
    HTTParty.post(Grafana.api_url(path), body: body)
  end
end
