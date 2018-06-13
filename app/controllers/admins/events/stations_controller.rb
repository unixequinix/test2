module Admins
  module Events
    class StationsController < Admins::Events::BaseController
      include ApplicationHelper
      include StationHelper

      before_action :set_station, except: %i[index new create]
      before_action :set_groups, only: %i[index new create edit update]

      def index
        @q = @current_event.stations.includes(:access_control_gates, :topup_credits, :station_catalog_items, :products)
                           .order(:hidden, :category, :name)
                           .where.not(category: "touchpoint")
                           .ransack(params[:q])
        @stations = @q.result
        authorize @stations
        @station = @current_event.stations.new
        @stations = @stations.group_by(&:group)
      end

      def show # rubocop:disable Metrics/AbcSize
        authorize @station
        @load_analytics_resources = true
        @items = @station.all_station_items
        @items.sort_by! { |i| i.class.sort_column.to_s } if @items.first
        @transactions = @station.transactions
        @pokes = @station.pokes
        @sales = - @station.pokes.where(credit: @current_event.credits).sales.is_ok.sum(:credit_amount)
        @sales_credits = - @station.pokes.where(credit: @current_event
          .credit).sales.is_ok.sum(:credit_amount)
        @operators = @station.pokes.pluck(:operator_id).uniq.count
        @devices = @station.pokes.pluck(:device_id).uniq.count
        @available_ticket_types = @current_event.ticket_types.where.not(id: @station.ticket_types)
        @current_ticket_types = @current_event.ticket_types.where(id: @station.ticket_types)

        money_cols = ["Action", "Description", "Money", "Payment Method", "Event Day", "Date Time", "Operator UID", "Operator Name", "Device"]
        @money = prepare_pokes(money_cols, pokes_onsite_money(@station))
        credit_cols = ["Action", "Description", "Credit Name", "Credits", "Operator UID", "Operator Name", "Device", "Event Day", "Date Time"]
        @credits = prepare_pokes(credit_cols, pokes_onsite_credits(@station))
        product_cols = ["Description", "Product Name", "Credit Name", "Credits", "Event Day", "Date Time", "Operator UID", "Operator Name", "Device"]
        @products = prepare_pokes(product_cols, pokes_sales(@station))
        stock_cols = ["Description", "Product Name", "Product Quantity", "Event Day", "Date Time", "Operator UID", "Operator Name", "Device"]
        @products_stock = prepare_pokes(stock_cols, pokes_sale_quantity(@station))
        access_cols = ["Event Day", "Date Time", "Direction", "Access"]
        @access_control = prepare_pokes(access_cols, pokes_access(@station))
        ticket_cols = ['Action', 'Description', 'Location', 'Station Type', 'Station Name', 'Event Day', 'Date Time', 'Customer ID', 'Customer UID', 'Customer Name', 'Operator UID', 'Operator Name', 'Device', 'Catalog Item', 'Ticket Type', 'Ticket Code', 'Redeemed', 'Total Tickets']
        @checkin_ticket_type = prepare_pokes(ticket_cols, pokes_checkin(@station))
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
