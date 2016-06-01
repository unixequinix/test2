class Admins::Events::CatalogItemsController < Admins::Events::BaseController
  def update
    @item = CatalogItem.find(params[:id]).update_attributes(permitted_params)
    render json: @item
  end

  private

  def permitted_params
    params.require(:catalog_item).permit(:id, :name, :description)
  end
end
