class Admins::Events::ProductsController < Admins::Events::BaseController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

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
      flash.now[:error] = I18n.t("errors.messages.station_dependent")
      set_presenter
      render :index
    end
  end

  def destroy_multiple
    products = params[:products]
    if products
      @fetcher.products.where(id: products.keys).each do |product|
        flash[:error] = product.errors.full_messages.join(". ") unless product.destroy
      end
    end
    redirect_to admins_event_products_path(current_event)
  end

  def import # rubocop:disable Metrics/AbcSize
    event = current_event.event
    alert = "Seleccione un archivo para importar"
    redirect_to(admins_event_products_path(event), alert: alert) && return unless params[:file]
    lines = params[:file][:data].tempfile.map { |line| line.split(";") }
    lines.delete_at(0)

    lines.each do |name, is_alcohol|
      Product.find_or_create_by!(event: event, name: name, is_alcohol: is_alcohol)
    end

    redirect_to(admins_event_products_path(event), notice: "Products imported")
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
