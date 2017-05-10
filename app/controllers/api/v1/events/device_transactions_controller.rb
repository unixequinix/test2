class Api::V1::Events::DeviceTransactionsController < Api::V1::Events::BaseController
  def create
    counter = @current_event.device_transactions.where(device_uid: permitted_params[:device_uid]).count + 1
    device = @current_event.devices.find_or_create_by!(mac: permitted_params[:device_uid])
    transaction = @current_event.device_transactions.new(permitted_params.merge(counter: counter, device: device))

    if transaction.save
      render(status: :created, json: :created)
    else
      render json: transaction.errors, status: :unprocessable_entity
    end
  end

  private

  def permitted_params
    # params.permit!.to_h[:_json].first.slice(:action, :device_uid, :initialization_type, :number_of_transactions, :battery)
    params.require(:device_transaction).permit(:action, :device_uid, :initialization_type, :number_of_transactions, :battery)
  end
end
