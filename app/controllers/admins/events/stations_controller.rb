module Admins
  module Events
    class StationsController < Admins::Events::BaseController
      include ApplicationHelper
      include StationHelper

      before_action :set_station, except: %i[index new create]
      before_action :set_groups, only: %i[index new create edit update]

      def index
        @q = policy_scope(@current_event.stations).includes(:access_control_gates, :topup_credits, :station_catalog_items, :products)
                                                  .order(:hidden, :category, :name)
                                                  .where.not(category: %w[customer_portal sync vault touchpoint operator_permissions gtag_recycler gtag_replacement yellow_card])
                                                  .ransack(params[:q])
        @stations = @q.result
        authorize @stations
        @station = @current_event.stations.new
        @stations = @stations.group_by(&:group)
      end

      def show
        authorize @station
        @load_analytics_resources = true
        @items = @station.all_station_items
        @items.sort_by! { |i| i.class.sort_column.to_s } if @items.first
        @available_ticket_types = @current_event.ticket_types.where.not(id: @station.ticket_types)
        @current_ticket_types = @current_event.ticket_types.where(id: @station.ticket_types)
        @catalog_items_collection = @current_event.catalog_items.order(:name).not_credits.where.not(id: @station.station_catalog_items.pluck(:catalog_item_id)).group_by { |item| item.type.underscore.humanize.pluralize }

        access_cols = ["Event Day", "Date Time", "Direction", "Access"]
        @access_control = prepare_pokes(access_cols, pokes_access(@station))
        ticket_cols = ['Action', 'Description', 'Location', 'Station Type', 'Station Name', 'Event Day', 'Date Time', 'Customer ID', 'Customer UID', 'Customer Name', 'Operator UID', 'Operator Name', 'Device', 'Catalog Item', 'Ticket Type', 'Ticket Code', 'Redeemed', 'Total Tickets']
        @checkin_ticket_type = prepare_pokes(ticket_cols, pokes_checkin(@station))
        ticket_val_cols = ['Action', 'Description', 'Location', 'Station Type', 'Station Name', 'Event Day', 'Date Time', 'Customer ID', 'Customer Name', 'Operator UID', 'Operator Name', 'Device', 'Catalog Item', 'Ticket Type', 'Ticket Code', 'Redeemed', 'Total Tickets']
        @validation_ticket_type = prepare_pokes(ticket_val_cols, pokes_ticket_validation(@station))
      end

      def new
        @station = @current_event.stations.new
        authorize @station
      end

      def create
        @station = @current_event.stations.new(permitted_params)
        authorize @station

        if @station.save
          redirect_to admins_event_station_path(@current_event, @station), notice: t("alerts.created")
        else
          flash.now[:alert] = t("alerts.error")
          render :new
        end
      end

      def edit; end

      def update
        respond_to do |format|
          if @station.update(permitted_params)
            format.html { redirect_to admins_event_station_path(@current_event, @station), notice: t("alerts.updated") }
            format.json { render status: :ok, json: @station }
          else
            format.html { render :edit }
            format.json { render json: @station.errors.to_json, status: :unprocessable_entity }
          end
        end
      end

      def hide
        @station.update!(hidden: true)
        respond_to do |format|
          format.html { redirect_to admins_event_station_path(@current_event, @station), notice: t("alerts.updated") }
          format.json { render json: @station }
        end
      end

      def unhide
        @station.update!(hidden: false)
        respond_to do |format|
          format.html { redirect_to admins_event_station_path(@current_event, @station), notice: t("alerts.updated") }
          format.json { render json: @station }
        end
      end

      def add_ticket_types
        ticket_types = @current_event.ticket_types.find(permitted_params['ticket_type_ids']) + @station.ticket_types
        @station.update(ticket_types: ticket_types)
        redirect_to admins_event_station_path(@current_event, @station), notice: t("alerts.updated")
      end

      def remove_ticket_types
        ticket_types = @station.ticket_types.where.not(id: permitted_params['ticket_type_ids']).pluck(:id)
        @station.update(ticket_type_ids: ticket_types)
        redirect_to admins_event_station_path(@current_event, @station), notice: t("alerts.updated")
      end

      def clone
        @station = @station.deep_clone(include: %i[station_catalog_items products topup_credits access_control_gates], validate: false)
        index = @station.name.index(' - ')
        name = index.nil? ? @station.name : @station.name.byteslice(0...index)
        @station.name = "#{name} - #{@current_event.stations.where('stations.name LIKE :l_name', l_name: "#{name}%").count}"
        @station.save!
        redirect_to [:admins, @current_event, @station], notice: t("alerts.created")
      end

      def destroy
        if @station.destroy
          flash[:notice] = t("alerts.destroyed")
        else
          flash[:error] = @pack.errors.full_messages.to_sentence
        end

        redirect_to admins_event_stations_path(@current_event, group: @station.group)
      end

      def sort
        params[:order].each_value { |value| @current_event.stations.find(value[:id]).update_attribute(:position, value[:position]) }
        render nothing: true
      end

      private

      def set_groups
        @group = params[:group]
        groups = Station::GROUPS
        groups = groups.slice(@group.to_sym) if @group
        @categories = groups.to_a.map { |key, arr| [key.to_s.humanize, arr.map { |s| [s.to_s.humanize, s] }] }
        @categories = @categories.map { |label, arr| [label, arr.delete_if { |__, key| key.in?(%i[customer_portal sync vault touchpoint operator_permissions gtag_recycler gtag_replacement yellow_card]) }] }.delete_if { |_, arr| arr.empty? }
      end

      def set_station
        id = params[:id] || params[:station_id]
        @station = @current_event.stations.find(id)
        authorize @station
        @group = @station.group
      end

      def permitted_params
        params.require(:station).permit(:name, :location, :category, :reporting_category, :address, :registration_num, :official_name, :hidden, :device_stats_enabled, ticket_type_ids: [])
      end
    end
  end
end
