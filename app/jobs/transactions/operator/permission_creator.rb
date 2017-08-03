class Transactions::Operator::PermissionCreator < Transactions::Base
  TRIGGERS = %w[record_operator_permission].freeze

  queue_as :low

  def perform(atts)
    event = Event.find(atts[:event_id])
    station = event.stations.find_by(station_event_id: atts[:station_permission_id])

    begin
      permission = event.operator_permissions.find_or_create_by!(role: atts[:role], group: atts[:group], station: station)
      event.transactions.find(atts[:transaction_id]).update!(catalog_item_id: permission.id)
    rescue ActiveRecord::RecordNotUnique
      retry
    end
  end
end
