class Admins::OnlineProductsController < Admin::BaseController

  def index
    @online_products = OnlineProduct.all
  end

  def new
    @online_product = OnlineProduct.new
  end

  def create
    @online_product = OnlineProduct.new(permitted_params)
    if @online_product.save
      flash[:notice] = "created TODO"
      redirect_to admin_online_products_url
    else
      flash[:error] = "ERROR TODO"
      render :new
    end
  end

  def edit
    @online_product = OnlineProduct.find(params[:id])
  end

  def update
    @online_product = OnlineProduct.find(params[:id])
    if @online_product.update(permitted_params)
      flash[:notice] = "updated TODO"
      redirect_to admin_online_products_url
    else
      flash[:error] = "ERROR"
      render :edit
    end
  end

  def destroy
    @online_product = OnlineProduct.find(params[:id])
    @online_product.destroy!
    flash[:notice] = "destroyed TODO"
    redirect_to admin_online_products_url
  end

  private

  def permitted_params
    params.require(:online_product).permit(:name, :description, :amount)
  end

end
