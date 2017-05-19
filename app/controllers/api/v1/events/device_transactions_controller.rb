class Api::V1::Events::DeviceTransactionsController < Api::V1::Events::BaseController
  def create
    permitted_params.each do |atts|
      next if atts.empty?
      counter = @current_event.device_transactions.where(device_uid: atts[:device_uid]).count + 1
      device = Device.find_or_create_by!(mac: atts[:device_uid].downcase)
      @current_event.devices << device unless @current_event.devices.includes?(device)
      @current_event.device_transactions.create!(atts.merge(counter: counter, device: device))
    end

    render(status: :created, json: :created)
  end

  private

  def permitted_params
    all_params = params.permit!.to_h.symbolize_keys
    all_params = [all_params[:device_transaction]] + [all_params[:_json]].flatten
    all_params.compact.flatten.map { |atts| atts.symbolize_keys.slice(:action, :device_uid, :initialization_type, :number_of_transactions) }
  end
end
