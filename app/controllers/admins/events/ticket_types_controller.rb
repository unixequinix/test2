module Admins
  module Events
    class TicketTypesController < Admins::Events::BaseController
      before_action :set_ticket_type, except: %i[index new create]
      before_action :set_catalog_items, except: [:destroy]
      before_action :set_operator, only: %i[index new]

      def unban
        @ticket_type.tickets.update_all(banned: false)
        redirect_to [:admins, @current_event, @ticket_type], notice: "All tickets successfully unbanned"
      end

      def index
        @q = @current_event.ticket_types.where(operator: @operator_mode).includes(:ticketing_integration).order(%i[company name]).ransack(params[:q])
        @ticket_types = @q.result
        @catalog_items = @current_event.catalog_items.order(:type).map { |i| [i.id, i.name.humanize] }
        @ticket_counts = @current_event.tickets.group(:ticket_type_id).count
        @gtag_counts = @current_event.gtags.group(:ticket_type_id).count
        @integrations = @current_event.ticketing_integrations.order(%i[type]).includes(:ticket_types)
        authorize @ticket_types
        @ticket_types = @ticket_types.page(params[:page])
      end

      def show
        @q = @ticket_type.tickets.order(created_at: :desc).ransack(params[:q])
        @tickets = @q.result
        @tickets = @tickets.page(params[:page])
      end

      def new
        @ticket_type = @current_event.ticket_types.new(operator: @operator_mode)
        authorize @ticket_type
      end

      def create
        @ticket_type = @current_event.ticket_types.new(permitted_params)
        authorize @ticket_type
        if @ticket_type.save
          redirect_to admins_event_ticket_types_path(operator: @ticket_type.operator?), notice: t("alerts.created")
        else
          @operator_mode = @ticket_type.operator?
          flash.now[:alert] = t("alerts.error")
          render :new
        end
      end

      def edit
        @operator_mode = @ticket_type.operator?
      end

      def update
        @operator_mode = @ticket_type.operator?
        respond_to do |format|
          if @ticket_type.update(permitted_params)
            format.html { redirect_to admins_event_ticket_types_path(operator: @operator_mode), notice: t("alerts.updated") }
            format.json { render json: @ticket_type }
          else
            flash.now[:alert] = t("alerts.errors")
            format.html { render :edit }
            format.json { render json: @ticket_type.errors.to_json, status: :unprocessable_entity }
          end
        end
      end

      def destroy
        if @ticket_type.destroy
          redirect_to admins_event_ticket_types_path(@current_event), notice: t("alerts.destroyed")
        else
          redirect_to admins_event_ticket_types_path(@current_event, @ticket_type), alert: @ticket_type.errors.full_messages.to_sentence
        end
      end

      private

      def set_catalog_items
        @catalog_items = @current_event.catalog_items.group_by { |item| item.type.underscore.humanize.pluralize }
      end

      def set_ticket_type
        @ticket_type = @current_event.ticket_types.find(params[:id])
        authorize @ticket_type
      end

      def set_operator
        @operator_mode = params[:operator].present? && params[:operator].eql?("true")
      end

      def permitted_params
        params.require(:ticket_type).permit(:name, :catalog_item_id, :hidden, :operator)
      end
    end
  end
end
