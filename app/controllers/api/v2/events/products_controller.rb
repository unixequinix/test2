class Api::V2::Events::ProductsController < Api::V2::BaseController
  before_action :set_station
  before_action :set_product, only: %i[show update destroy]
  before_action :check_station_is_vendor

  # GET /products
  def index
    @products = @station.products
    authorize @products

    render json: @products
  end

  # GET /products/1
  def show
    render json: @product
  end

  # POST /products
  def create
    @product = @station.products.new(product_params)
    authorize @product

    if @product.save
      render json: @product, status: :created, location: [:admins, @current_event, @product]
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /products/1
  def update
    if @product.update(product_params)
      render json: @product
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  # DELETE /products/1
  def destroy
    @product.destroy
  end

  private

  def check_station_is_vendor
    render json: { errors: "Working with products on non-vendor stations" }, status: :unprocessable_entity unless @station.form.eql?(:pos)
  end

  def set_station
    @station = @current_event.stations.find(params[:station_id]) if params[:station_id]
  end

  def set_product
    @product = @station.products.find(params[:id])
    authorize @product
  end

  def product_params
    params.require(:product).permit(:name, :is_alcohol, :description, :vat, :price, :position)
  end
end
