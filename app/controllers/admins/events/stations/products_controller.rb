class Admins::Events::Stations::ProductsController < Admins::Events::BaseController
  before_action :set_station
  before_action :set_product, only: %i[update]

  def index
    @q = @station.products.ransack(params[:q])
    @products = @q.result
    authorize @products
    @products = @products.page(params[:page])
  end

  def update
    respond_to do |format|
      if @product.update(permitted_params)
        format.html { redirect_to admins_event_products_path, notice: t("alerts.updated") }
        format.json { render json: @product }
      else
        format.html { render :edit }
        format.json { render json: @product.errors.to_json, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_station
    @station = @current_event.stations.find(params[:station_id])
  end

  def set_product
    @product = @station.products.find(params[:id])
    authorize @product
  end

  def permitted_params
    params.require(:product).permit(:name, :description, :is_alcohol, :vat, :price, :hidden)
  end
end
