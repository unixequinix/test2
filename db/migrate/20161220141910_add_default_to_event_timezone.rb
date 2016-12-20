class AddDefaultToEventTimezone < ActiveRecord::Migration
  def change
    change_column_default :events, :timezone, "UTC"
    Event.all.each { |e| e.update(timezone: "UTC") if e.timezone.blank? }
  end
end
