class CreateTableApiMetrics < ActiveRecord::Migration[5.1]
  def change
    create_table :api_metrics do |t|
      t.references :user, index: true, foreign_key: true
      t.references :event, index: true, foreign_key: true
      t.string :controller, null: false
      t.string :action, null: false
      t.string :http_verb, null: false
      t.jsonb :request_params, default: "{}"
      t.datetime :received_at
    end
  end
end
