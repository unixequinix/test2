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
        if params[:name].to_s.eql?('ticket_master')
          @integration = @current_event.ticketing_integrations.find_or_initialize_by(integration_event_id: @current_event.id, integration_event_name: @current_event.name, type: TicketingIntegration::NAMES[params[:name].to_sym], token: @current_user.id)
          @integration.data[:events] = { "#{permitted_params[:data][:event_code]}": {} } if @integration.new_record?
          @integration.data[:events] = @integration.data[:events].merge("#{permitted_params[:data][:event_code]}": {
                                                                          begin_date: permitted_params[:data][:begin_date],
                                                                          end_date: permitted_params[:data][:end_date],
                                                                          access_control_system: permitted_params[:data][:access_control_system],
                                                                          system_id: permitted_params[:data][:system_id]
                                                                        })
        else
          @integration = @current_event.ticketing_integrations.new(permitted_params.merge(type: TicketingIntegration::NAMES[params[:name].to_sym]))
        end

        authorize(TicketingIntegration.new)

        if @integration.save
          redirect_to [:admins, @current_event, @integration]
        else
          flash.now[:alert] = t("alerts.error")
          render :new
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
