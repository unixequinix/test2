class Api::V1::Events::DeviceTransactionsController < Api::V1::Events::BaseController
  def create
    permitted_params.each do |atts|
      next if atts.empty?
      server_count = @current_event.transactions.where(device_uid: atts[:device_uid]).count
      new_atts = atts.slice(:action, :battery, :app_version, :number_of_transactions).merge(server_transactions: server_count)

      device = Device.find_or_create_by!(mac: atts[:device_uid].downcase)
      registration = @current_event.device_registrations.find_or_create_by!(device: device)
      registration.update!(new_atts)

      next unless atts[:action].downcase.in?(DeviceTransaction::ACTIONS)
      counter = @current_event.device_transactions.where(device_uid: atts[:device_uid]).count + 1
      t_atts = atts.merge(counter: counter, device: device)
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
