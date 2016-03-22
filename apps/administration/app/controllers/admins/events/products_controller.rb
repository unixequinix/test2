class Admins::Events::ProductsController < Admins::Events::BaseController
  def index
    set_presenter
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(permitted_params)
    if @product.save
      flash[:notice] = I18n.t("alerts.created")
      redirect_to admins_event_products_url
    else
      flash.now[:error] = @product.errors.full_messages.join(". ")
      render :new
    end
  end

  def edit
    @product = @fetcher.products.find(params[:id])
  end

  def update
    @product = @fetcher.products.find(params[:id])
    if @product.update_attributes(permitted_params)
      flash[:notice] = I18n.t("alerts.updated")
      redirect_to admins_event_products_url
    else
      flash.now[:error] = @product.errors.full_messages.join(". ")
      render :edit
    end
  end

  def destroy
    @product = @fetcher.products.find(params[:id])
    if @product.destroy
      flash[:notice] = I18n.t("alerts.destroyed")
      redirect_to admins_event_products_url
    else
      flash.now[:error] = I18n.t("errors.messages.catalog_item_dependent")
      set_presenter
      render :index
    end
  end

  private

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "Product".constantize.model_name,
      fetcher: @fetcher.products,
      search_query: params[:q],
      page: params[:page],
      include_for_all_items: [],
      context: view_context
    )
  end

  def permitted_params
    params.require(:product).permit(:id, :name, :description, :is_alcohol, :event_id)
  end
end
