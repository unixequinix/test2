class Admins::Events::CatalogItemsController < Admins::Events::BaseController
  def update
    @item = @current_event.catalog_items.find(params[:id])
    authorize @item

    if @item.update(permitted_params)
      render json: @item
    else
      render json: { errors: @item.errors }, status: :unprocessable_entity
    end
  end

  private

  def permitted_params
    params.require(:catalog_item).permit(:id, :name, :description, :initial_amount, :max_purchasable, :min_purchasable, :name, :step, :value)
  end
end
