class AddDefaultToEventTimezone < ActiveRecord::Migration[5.0]
  def change
    change_column_default :events, :timezone, "UTC"
    Event.all.each { |e| e.update(timezone: "UTC") if e.timezone.blank? }
  end
end
