module Admins
  module Events
    class TicketingIntegrationsController < Admins::Events::BaseController
      before_action :set_integration, except: %i[new create]

      def new
        @integration = @current_event.ticketing_integrations.new(type: TicketingIntegration::NAMES[params[:name].to_sym])
        authorize(TicketingIntegration.new)

        return unless params[:name].in?(TicketingIntegration::AUTOMATIC_INTEGRATIONS)
        @integration.save!

        cookies.signed[:event_slug] = @current_event.slug
        cookies.signed[:ticketing_integration_id] = @integration.id

        redirect_to [:admins, @current_event, @integration]
      end

      def create
        # TODO[ticketmaster] remove after bbf
        ticket_master = params[:name].to_s.eql?('ticket_master') && @current_event.is_ticketmaster?
        @integration = @current_event.ticketing_integrations.new(integration_event_id: @current_event.id, integration_event_name: @current_event.name, type: TicketingIntegration::NAMES[params[:name].to_sym], token: @current_user.id) if ticket_master
        @integration = @current_event.ticketing_integrations.new(permitted_params.merge(type: TicketingIntegration::NAMES[params[:name].to_sym])) unless ticket_master
        authorize(TicketingIntegration.new)

        if @integration.save
          # TODO[ticketmaster] remove after bbf
          redirect_to admins_event_ticketing_integration_ticket_master_connect_path(@current_event, @integration) if ticket_master
          redirect_to [:admins, @current_event, @integration] unless ticket_master
        else
          # TODO[ticketmaster] remove after bbf
          flash.now[:alert] = t("alerts.error")
          render :new unless ticket_master
          redirect_to admins_event_ticket_types_path(@current_event), alert: "Event already connected" if ticket_master
        end
      end

      def destroy
        ticket_types = @current_event.ticket_types.where(ticketing_integration: @integration)
        @current_event.tickets.where(ticket_type: ticket_types).delete_all
        ticket_types.delete_all
        @integration.destroy!
        redirect_to [:admins, @current_event, :ticket_types], notice: "Integration and all tickets associated have been destroyed"
      end

      def activate
        @integration.active!
        redirect_to [:admins, @current_event, :ticket_types], notice: "Integration was activated, it will start sync again"
      end

      def deactivate
        @integration.inactive!
        redirect_to [:admins, @current_event, :ticket_types], notice: "Integration was deactivated, it will not sync anymore"
      end

      private

      def set_integration
        @integration = @current_event.ticketing_integrations.find(params[:id])
        authorize(@current_event.ticketing_integrations.new)
      end

      def permitted_params
        params.require(:ticketing_integration).permit(:name, :client_key, :client_secret, data: {})
      end
    end
  end
end
