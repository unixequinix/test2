class Api::V1::StationGroupSerializer < Api::V1::BaseSerializer
  attributes :station_group, :icon_slug, :stations

  def station_group
    object.name
  end

  def stations
    object.stations
          .where(event: current_event)
          .where.not(category: "customer_portal")
          .order(created_at: :desc)
          .map { |s| Api::V1::StationSerializer.new(s) }
  end
end
