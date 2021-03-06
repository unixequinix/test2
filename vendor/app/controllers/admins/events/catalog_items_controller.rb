module Admins
  module Events
    class CatalogItemsController < Admins::Events::BaseController
      def update
        @item = @current_event.catalog_items.find(params[:id])
        authorize @item

        if @item.update(permitted_params)

          @current_event.virtual_credit.update(value: @item.value) if @item.is_a?(Credit)

          render json: @item
        else
          render json: @item.errors.to_json, status: :unprocessable_entity
        end
      end

      private

      def permitted_params
        params.require(:catalog_item).permit(:id, :name, :description, :name, :value, :symbol)
      end
    end
  end
end
