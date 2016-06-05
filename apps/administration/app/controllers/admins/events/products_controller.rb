class Admins::Events::ProductsController < Admins::Events::BaseController
  before_action :set_product, except: [:index, :new, :create]

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
  end

  def update
    respond_to do |format|
      if @product.update_attributes!(permitted_params)
        format.html { redirect_to admins_event_products_url, notice: I18n.t("alerts.updated") }
      else
        format.html do
          flash.now[:error] = @product.errors.full_messages.join(". ")
          render :edit
        end
      end
      format.json { render json: @product }
    end
  end

  def destroy
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

  def set_product
    @product = @fetcher.products.find(params[:id])
  end

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
