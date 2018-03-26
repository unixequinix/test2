class RecreateApiMetrics < ActiveRecord::Migration[5.1]
  def change
    return if table_exists?(:api_metrics)
    create_table "api_metrics", force: :cascade do |t|
      t.bigint "user_id"
      t.bigint "event_id"
      t.string "controller", null: false
      t.string "action", null: false
      t.string "http_verb", null: false
      t.jsonb "request_params", default: "{}"
      t.datetime "received_at"
      t.index ["event_id"], name: "index_api_metrics_on_event_id"
      t.index ["user_id"], name: "index_api_metrics_on_user_id"
    end
  end
end
