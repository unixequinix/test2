module Admins
  module Events
    class OrderItemsController < Admins::Events::BaseController
      before_action :set_order_item, only: %i[update]

      def update
        respond_to do |format|
          if @order_item.update(permitted_params)
            format.html { redirect_to [:admins, @current_event, @order_item], notice: t("alerts.updated") }
            format.json { render status: :ok, json: @order_item }
          else
            format.html { render :edit }
            format.json { render json: @order_item.errors.to_json, status: :unprocessable_entity }
          end
        end
      end

      def show
        authorize @order
      end

      private

      def set_order_item
        @order_item = @current_event.orders.find(params[:order_id]).order_items.find(params[:id])
        authorize @order_item
      end

      def permitted_params
        params.require(:order_item).permit(:redeemed)
      end
    end
  end
end
