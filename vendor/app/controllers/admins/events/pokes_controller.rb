module Admins
  module Events
    class PokesController < Admins::Events::BaseController
      include ActionController::Live
      include Analytics::ExcelHelper

      before_action :set_relations, only: %i[index]

      def index
        @pokes = params[:q].present? ? @current_event.pokes : @current_event.pokes.none
        @q = @pokes.search(params[:q])
        @pokes = @q.result.page(params[:page]).includes(:customer, :station, :operator, :credit).order(date: :desc)
        authorize @pokes
      end

      def download
        @pokes = @current_event.pokes.search(params[:q]).result.includes(:customer, :station, :operator, :credit, :product).order(date: :desc)
        @credits = @current_event.credits
        authorize @pokes
        respond_to do |format|
          format.pdf { render pdf: "pokes.pdf", disposition: "inline" }
          format.xls { handle_response(@current_event, @pokes, response) }
        end
      end

      def show
        @poke = @current_event.pokes.find(params[:id])
        authorize @poke
      end

      def update
        @poke = @current_event.pokes.find(params[:id])
        authorize @poke

        respond_to do |format|
          if @poke.update(permitted_params)
            format.html { redirect_to [:admins, @current_event, @poke], notice: t("alerts.updated") }
            format.json { render status: :ok, json: @poke }
          else
            format.html { render :edit }
            format.json { render json: @poke.errors.to_json, status: :unprocessable_entity }
          end
        end
      end

      private

      def permitted_params
        params.require(:poke).permit(:credit_id, :credit_amount, :final_balance)
      end

      def set_relations
        @stations = @current_event.stations.where(id: @current_event.pokes.select(:station_id).distinct.pluck(:station_id))
        @products = Product.where(id: @current_event.pokes.select(:product_id).distinct.pluck(:product_id)).order(:station_id)
        @ticket_types = @current_event.ticket_types.where(id: @current_event.pokes.select(:ticket_type_id).distinct.pluck(:ticket_type_id))
        @devices = @current_event.devices.where(id: @current_event.pokes.select(:device_id).distinct.pluck(:device_id))
        @credits = @current_event.credits
      end
    end
  end
end
