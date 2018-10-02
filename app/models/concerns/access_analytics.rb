module AccessAnalytics
  extend ActiveSupport::Concern
  include BaseAnalytics

  # Checkins
  #
  def checkins(station_filter: [], ticket_type_filter: [], operator_filter: [], credential_type_filter: [], catalog_item_filter: [])
    pokes.where(action: %w[checkin ticket_validation]).with_station(station_filter).with_catalog_item(catalog_item_filter).with_ticket_type(ticket_type_filter).with_operator(operator_filter).with_description(credential_type_filter).is_ok
  end

  def count_checkins(grouping: :day, station_filter: [], ticket_type_filter: [], operator_filter: [], credential_type_filter: [], catalog_item_filter: [])
    checkins(station_filter: station_filter, ticket_type_filter: ticket_type_filter, operator_filter: operator_filter, credential_type_filter: credential_type_filter, catalog_item_filter: catalog_item_filter).group_by_period(grouping, :date).count
  end

  def checkins_total(station_filter: [], ticket_type_filter: [], operator_filter: [], credential_type_filter: [], catalog_item_filter: [])
    checkins(station_filter: station_filter, ticket_type_filter: ticket_type_filter, operator_filter: operator_filter, credential_type_filter: credential_type_filter, catalog_item_filter: catalog_item_filter).count
  end

  def count_checked_in_customers(grouping: :day, station_filter: [], ticket_type_filter: [], operator_filter: [], credential_type_filter: [], catalog_item_filter: [])
    ids = checkins(station_filter: station_filter, ticket_type_filter: ticket_type_filter, operator_filter: operator_filter, credential_type_filter: credential_type_filter, catalog_item_filter: catalog_item_filter).distinct(:customer_id).pluck(:customer_id)
    customers.where(id: ids).group_by_period(grouping, :created_at).count
  end

  def checked_in_customers_total(station_filter: [], ticket_type_filter: [], operator_filter: [], credential_type_filter: [], catalog_item_filter: [])
    ids = checkins(station_filter: station_filter, ticket_type_filter: ticket_type_filter, operator_filter: operator_filter, credential_type_filter: credential_type_filter, catalog_item_filter: catalog_item_filter).distinct(:customer_id).pluck(:customer_id)
    customers.where(id: ids).count
  end

  # Access Control
  #
  def checkpoints(station_filter: [], operator_filter: [], catalog_item_filter: [], direction_filter: [])
    pokes.where(action: "checkpoint").with_station(station_filter).with_catalog_item(catalog_item_filter).with_operator(operator_filter).with_direction(direction_filter).is_ok
  end

  def count_checkpoints(grouping: :day, station_filter: [], operator_filter: [], catalog_item_filter: [], direction_filter: [])
    checkpoints(station_filter: station_filter, operator_filter: operator_filter, catalog_item_filter: catalog_item_filter, direction_filter: direction_filter).group_by_period(grouping, :date).count
  end

  def checkpoints_total(station_filter: [], operator_filter: [], catalog_item_filter: [], direction_filter: [])
    checkpoints(station_filter: station_filter, operator_filter: operator_filter, catalog_item_filter: catalog_item_filter, direction_filter: direction_filter).count
  end

  # Exhibitor notes
  #
  def engagement(station_filter: [], priority_filter: [])
    pokes.where(action: "exhibitor_note").with_station(station_filter).with_priority(priority_filter).is_ok
  end

  def count_engagement(grouping: :day, station_filter: [], priority_filter: [])
    engagement(station_filter: station_filter, priority_filter: priority_filter).group_by_period(grouping, :date).count
  end

  def unique_engagement(grouping: :day, station_filter: [], priority_filter: [])
    engagement(priority_filter: priority_filter, station_filter: station_filter).select(:date, :customer_id).distinct(:customer_id).group_by_period(grouping, :date).count(:customer_id)
  end

  def average_engagement(grouping: :day, station_filter: [], priority_filter: [])
    engagement(priority_filter: priority_filter, station_filter: station_filter).group_by_period(grouping, :date).average(:priority)
  end

  def engagement_total(station_filter: [], priority_filter: [])
    engagement(station_filter: station_filter, priority_filter: priority_filter).count
  end
end
