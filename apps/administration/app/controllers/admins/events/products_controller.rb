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

  def sample_csv
    header = %w(name description is_alcohol)
    data = [["Beer", "Franziskaner beer", "true"], ["Hotdog", "Hotdog with onion", "false"]]

    csv_file = Csv::CsvExporter.sample(header, data)
    respond_to do |format|
      format.csv { send_data(csv_file) }
    end
  end

  def import # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    event = current_event.event
    alert = "Seleccione un archivo para importar"
    redirect_to(admins_event_products_path(event), alert: alert) && return unless params[:file]
    file = params[:file][:data].tempfile.path

    CSV.foreach(file, headers: true, col_sep: ";").with_index do |row, i|
      atts = {
        name: row.field("name"),
        description: row.field("description"),
        is_alcohol: row.field("is_alcohol")
      }
      product = event.products.find_by(name: row.field("name")) || event.products.new
      product.assign_attributes(atts)

      unless product.save
        errors = "Line #{i}: " + product.errors.full_messages.join(". ")
        return redirect_to(admins_event_products_path(event), alert: errors)
      end
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
