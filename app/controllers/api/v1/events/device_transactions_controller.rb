class Api::V1::Events::DeviceTransactionsController < Api::V1::Events::BaseController
  def create
    render(status: :bad_request, json: :bad_request) && return unless params[:_json]

    params.permit!.to_h[:_json].each_with_index do |atts, _index|
      atts = atts.slice(:action, :device_uid, :initialization_type, :number_of_transactions)
      counter = @current_event.device_transactions.where(device_uid: atts[:device_uid]).count + 1
      device = @current_event.devices.find_or_create_by!(mac: atts[:device_uid])
      transaction = @current_event.device_transactions.new(atts.merge(counter: counter, device: device))
      transaction.save!
    end

    render(status: :created, json: :created)
  end

  private

  def permitted_params
    # params.require(:device_transaction).permit(:action, :device_uid, :initialization_type, :number_of_transactions, :battery)
  end
end
