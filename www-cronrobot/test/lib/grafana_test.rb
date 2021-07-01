require "test_helper"

class GrafanaTest < ActiveSupport::TestCase
  test "alerts_dashboard_ids_query - happy path" do
    result = Grafana.alerts_dashboard_ids_query([1,2,3])
    
    assert result == "dashboardId=1&dashboardId=2&dashboardId=3"
  end
end
