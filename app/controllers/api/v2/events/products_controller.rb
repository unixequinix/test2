class Api::V2::Events::ProductsController < Api::V2::BaseController
  before_action :set_product, only: %i[show update destroy]

  # GET /products
  def index
    @products = @current_event.products
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

  # Use callbacks to share common setup or constraints between actions.
  def set_product
    @product = @current_event.products.find(params[:id])
    authorize @product
  end

  # Only allow a trusted parameter "white list" through.
  def product_params
    params.require(:product).permit(:name, :is_alcohol, :description, :vat)
  end
end
