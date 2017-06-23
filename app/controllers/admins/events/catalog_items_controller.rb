class Admins::Events::CatalogItemsController < Admins::Events::BaseController
  def update
    @item = @current_event.catalog_items.find(params[:id])
    authorize @item

    if @item.update(permitted_params)
      render json: @item
    else
      render json: @item.errors.to_json, status: :unprocessable_entity
    end
  end

  private

  def permitted_params
    params.require(:catalog_item).permit(:id, :name, :description, :name, :value)
  end
end
