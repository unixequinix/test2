class Api::V1::Events::DeviceTransactionsController < Api::V1::Events::BaseController
  def create
    permitted_params.each do |atts|
      next if atts.empty?
      action = atts[:action].downcase
      server_count = @current_event.transactions.where(device_uid: atts[:device_uid]).count
      new_atts = atts.slice(:battery, :number_of_transactions).merge(server_transactions: server_count, app_version: params[:app_version])
      new_atts[:action] = action if action.in?(DeviceTransaction::ACTIONS)

      device = Device.find_or_create_by!(mac: atts[:device_uid].downcase)
      registration = @current_event.device_registrations.find_or_create_by!(device: device)
      registration.update!(new_atts)

      Alert.propagate(@current_event, "has no name", :low, registration) if device.asset_tracker.blank?

      next unless action.in?(DeviceTransaction::ACTIONS)
      counter = @current_event.device_transactions.where(device_uid: atts[:device_uid]).count + 1
      t_atts = atts.merge(counter: counter, device: device, server_transactions: server_count)
      @current_event.device_transactions.create!(t_atts)
    end

    render(status: :created, json: :created)
  end

  private

  def permitted_params
    all_params = params.permit!.to_h.symbolize_keys
    all_params = [all_params[:device_transaction]] + [all_params[:_json]].flatten
    all_params.compact.flatten.map do |atts|
      atts.symbolize_keys.slice(:action, :device_uid, :initialization_type, :number_of_transactions, :battery, :app_version)
    end
  end
end
