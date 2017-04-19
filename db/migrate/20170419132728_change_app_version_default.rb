class ChangeAppVersionDefault < ActiveRecord::Migration[5.0]
  def change
    change_column_default :events, :app_version, "all"
    Event.all.map { |e| e.update(app_version: "all") if e.app_version.eql?("5.7.0") }
  end
end
