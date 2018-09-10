module Admins
  module Events
    module Stations
      class ProductsController < Admins::Events::BaseController
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

        def sample_csv
          authorize @station.products.new
          header = %w[name description is_alcohol price vat hidden]
          data = [["Gin & Tonic", "Best GinTonic ever", "true", "9.5", "0.5", "false"], ["Water", "Just clear and fresh water", "false", "1", "0", "false"]]

          respond_to do |format|
            format.csv { send_data(CsvExporter.sample(header, data)) }
          end
        end

        def import
          authorize @station.products.new
          redirect_to(admins_event_station_path(@current_event, @station), alert: t("admin.tickets.import.empty_file")) && return unless params[:file]
          file = params[:file][:data].tempfile.path
          count = 0

          begin
            products = []
            CSV.foreach(file, headers: true, col_sep: ";").with_index do |row, _i|
              products << row.to_hash unless @station.products.find_by(name: row.field('name'))
            end
            products.each do |row|
              @station.products.create!(row)
              count += 1
            end
          rescue StandardError
            return redirect_to(admins_event_station_path(@current_event, @station), alert: t("alerts.import.error"))
          end

          redirect_to(admins_event_station_path(@current_event, @station), notice: t("alerts.import.success", count: count, item: "Products"))
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
    end
  end
end
