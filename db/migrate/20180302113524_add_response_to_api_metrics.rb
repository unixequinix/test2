class AddResponseToApiMetrics < ActiveRecord::Migration[5.1]
  def change
    add_column :api_metrics, :response, :string
    ApiMetric.update_all(response: "200")
  end
end
