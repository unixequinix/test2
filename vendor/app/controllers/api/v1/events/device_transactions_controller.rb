module Api
  module V1
    module Events
      class DeviceTransactionsController < Api::V1::EventsController
        def create
          permitted_params.each do |atts|
            next if atts.empty?

            action = atts[:action].downcase
            server_count = @current_event.transactions.where(device: @device).count

            new_atts = atts.slice(:battery, :number_of_transactions)
            new_atts[:current_time] = params[:current_time]
            new_atts[:server_transactions] = server_count
            new_atts[:app_version] = params[:app_version]
            new_atts[:action] = action if action.in?(DeviceTransaction::ACTIONS)
            new_atts[:initialization_type] = atts[:initialization_type]

            registration = @current_event.device_registrations.find_or_create_by!(device: @device)
            registration.update!(new_atts)

            Alert.propagate(@current_event, registration, "has no name", :low) if @device.asset_tracker.blank?

            next unless action.in?(DeviceTransaction::ACTIONS)

            counter = @current_event.device_transactions.where(device_id: atts[:device_id]).count + 1
            t_atts = atts.merge(counter: counter, device: @device, server_transactions: server_count)
            @current_event.device_transactions.create!(t_atts)

            registration.update!(allowed: true) if action.eql?("lock_device")
            registration.update!(allowed: false) if action.eql?("device_initialization")
          end

          render(status: :created, json: :created)
        end

        private

        def permitted_params
          all_params = params.permit!.to_h.symbolize_keys
          all_params = [all_params[:device_transaction]] + [all_params[:_json]].flatten
          all_params.compact.flatten.map do |atts|
            atts.symbolize_keys.slice(:action, :device_id, :initialization_type, :number_of_transactions, :battery)
          end
        end
      end
    end
  end
end
