class Api::V2::Events::ProductsController < Api::V2::BaseController
  before_action :set_product, only: %i[show update destroy]
  before_action :set_station
  before_action :set_price, only: %i[create update]

  # GET /products
  def index
    @products = @station ? @station.products : @current_event.products
    authorize @products

    render json: @products
  end

  # GET /products/1
  def show
    render json: @product
  end

  # POST /products
  def create
    @product = @current_event.products.new(product_params)
    authorize @product

    if @product.save
      @station.station_products.create!(price: price, product: @product) if @price
      render json: @product, status: :created, location: [:admins, @current_event, @product]
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /products/1
  def update
    if @product.update(product_params)
      @station.station_products.find_by(product: @product).update(price: @price) if @price
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

  def set_price
    @price = params[:product].delete(:price) if @station
  end

  def set_station
    @station = @current_event.stations.find(params[:station_id]) if params[:station_id]
  end

  def set_product
    @product = @station ? @station.products.find(params[:id]) : @current_event.products.find(params[:id])
    authorize @product
  end

  def product_params
    params.require(:product).permit(:name, :is_alcohol, :description, :vat, :price)
  end
end
