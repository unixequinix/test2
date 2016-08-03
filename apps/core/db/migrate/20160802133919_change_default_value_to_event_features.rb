class ChangeDefaultValueToEventFeatures < ActiveRecord::Migration
  def change
    Event.all.each do |event|
      features = event.features + 384
      event.update!(features: features)
    end

    change_column_default :events, :features, 416
  end
end
