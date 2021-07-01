class AddGrafanaDashboardIdToSchedulers < ActiveRecord::Migration[7.0]
  def change
    add_column :schedulers, :grafana_dashboard_id, :string
  end
end
