module Admins
  module Events
    module Stations
      class StationItemsController < Admins::Events::BaseController
        before_action :set_station
        before_action :set_item, only: %i[update destroy]

        ITEMS = { product: Product, station_catalog_item: StationCatalogItem, access_control_gate: AccessControlGate, topup_credit: TopupCredit }.freeze

        def create
          @group = @station.group
          @items = @station.all_station_items
          @items.sort_by!(&@items.first.class.sort_column) if @items.first
          @item = @klass.new(permitted_params.merge(station: @station))
          authorize(@item)

          if @item.save
            redirect_to [:admins, @current_event, @station], notice: t("alerts.created")
          else
            flash.now[:alert] = t("alerts.error")
            @transactions = []
            @devices = []
            @operators = 0
            render 'admins/events/stations/show'
          end
        end

        def update
          respond_to do |format|
            if @item.update(permitted_params)
              format.json { render status: :ok, json: @item }
            else
              format.json { render json: @item.errors.to_json, status: :unprocessable_entity }
            end
          end
        end

        def destroy
          if @item.destroy
            flash[:notice] = t("alerts.destroyed")
          else
            flash[:error] = @pack.errors.full_messages.to_sentence
          end
          redirect_to [:admins, @current_event, @item.station]
        end

        def sort
          skip_authorization
          params[:order].to_unsafe_h.each_pair do |_key, value|
            next unless value[:id]
            @klass.find(value[:id]).update(position: value[:position].to_i - 1)
          end

          head(:ok)
        end

        private

        def set_station
          @station = @current_event.stations.find(params[:station_id])
          @klass = ITEMS[params[:item_type].to_sym]
        end

        def set_item
          @item = @klass.find_by!(station: @station, id: params[:id])
          authorize @item
        end

        def permitted_params
          params.require(params[:item_type]).permit(:direction, :access_id, :catalog_item_id, :price, :name, :amount, :credit_id, :hidden, :position, :vat)
        end
      end
    end
  end
end
