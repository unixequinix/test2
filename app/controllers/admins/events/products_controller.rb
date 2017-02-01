class Admins::Events::ProductsController < Admins::Events::BaseController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  def index
    @q = @current_event.products.ransack(params[:q])
    @products = @q.result
    authorize @products
    @products = @products.page(params[:page])
  end

  def new
    @product = Product.new
    authorize @product
  end

  def create
    @product = Product.new(permitted_params)
    authorize @product
    if @product.save
      redirect_to admins_event_products_path, notice: t("alerts.created")
    else
      flash.now[:error] = t("alerts.error")
      render :new
    end
  end

  def update
    respond_to do |format|
      if @product.update_attributes(permitted_params)
        format.html { redirect_to admins_event_products_path, notice: t("alerts.updated") }
      else
        format.html { render :edit }
      end

      format.json { render json: @product }
    end
  end

  def destroy
    if @product.destroy
      redirect_to admins_event_products_path, notice: t("alerts.destroyed")
    else
      redirect_to admins_event_product_path(@current_event, @product), error: @product.errors.full_messages.to_sentence
    end
  end

  def sample_csv
    authorize @current_event.products.new
    header = %w(name description is_alcohol)
    data = [["Beer", "Franziskaner beer", "true"], ["Hotdog", "Hotdog with onion", "false"]]

    csv_file = CsvExporter.sample(header, data)
    respond_to do |format|
      format.csv { send_data(csv_file) }
    end
  end

  def import # rubocop:disable Metrics/AbcSize
    authorize @current_event.products.new
    alert = "Seleccione un archivo para importar"
    redirect_to(admins_event_products_path(@current_event), alert: alert) && return unless params[:file]
    file = params[:file][:data].tempfile.path

    CSV.foreach(file, headers: true, col_sep: ";", encoding: "ISO8859-1:utf-8").with_index do |row, i|
      atts = { name: row.field("name"), description: row.field("description"), is_alcohol: row.field("is_alcohol") }
      product = @current_event.products.find_by(name: row.field("name")) || @current_event.products.new
      product.assign_attributes(atts)

      next if product.save
      errors = "Line #{i}: " + product.errors.full_messages.join(". ")
      return redirect_to(admins_event_products_path(@current_event), alert: errors)
    end

    redirect_to(admins_event_products_path(@current_event), notice: "Products imported")
  end

  private

  def set_product
    @product = @current_event.products.find(params[:id])
    authorize @product
  end

  def permitted_params
    params.require(:product).permit(:id, :name, :product_type, :description, :is_alcohol, :vat, :event_id)
  end
end
