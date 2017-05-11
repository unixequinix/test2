class Api::V1::Events::DeviceTransactionsController < Api::V1::Events::BaseController
  def create
    permitted_params.each do |atts|
      atts = atts.slice(:action, :device_uid, :initialization_type, :number_of_transactions)
      counter = @current_event.device_transactions.where(device_uid: atts[:device_uid]).count + 1
      device = @current_event.devices.find_or_create_by!(mac: atts[:device_uid])
      @current_event.device_transactions.create!(atts.merge(counter: counter, device: device))
    end

    render(status: :created, json: :created)
  end

  private

  def permitted_params
    all_params = params.permit!.to_h
    all_params = [all_params[:device_transaction]] + [all_params[:_json]].flatten
    all_params.map { |atts| atts.slice(:action, :device_uid, :initialization_type, :number_of_transactions) }
  end
end
