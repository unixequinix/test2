module Admins
  module Events
    class TicketMasterController < Admins::Events::BaseController
      protect_from_forgery
      before_action :set_integration

      def connect
        if @integration.update(status: "active", token: @current_event.id)
          redirect_to [:admins, @current_event, @integration, :import_tickets]
        else
          redirect_to [:admins, @current_event, :ticket_types], alert: "Event already connected, choose another"
        end
      end

      def import_tickets
        @integration.ignore_last_import_date = true
        @integration.import
        redirect_to [:admins, @current_event, :ticket_types], notice: "You are connected, tickets are being imported now"
      end

      def destroy
        @integration.data[:events].delete(params[:name])
        if @integration.save!
          redirect_to request.referer, notice: "Configuration has been correctly removed"
        else
          flash[:error] = 'Something went wrong'
          redirect_to [:admins, @current_event, :ticket_types]
        end
      end

      private

      def set_integration
        @integration = @current_event.ticket_master_ticketing_integrations.find(params[:ticketing_integration_id])
        authorize(@current_event.ticketing_integrations.new)
      end
    end
  end
end
