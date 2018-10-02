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
              format.html { redirect_to admins_event_station_path(@current_event, @product.station), notice: t("alerts.updated") }
              format.json { render json: @product }
            else
              format.html { redirect_to admins_event_station_path(@current_event, @product.station), alert: "Product price error: #{@product.errors.full_messages.sentence}" }
              format.json { render json: @product.errors.to_json, status: :unprocessable_entity }
            end
          end
        end

        def sample_csv
          authorize @station.products.new
          currencies = @current_event.currencies.pluck(:type)
          header = %w[name description is_alcohol vat hidden].push(currencies.each(&:downcase)).flatten
          data = [["Gin & Tonic", "Best GinTonic ever", "true", "0.5", "false"].push(currencies.map { |_cu| Random.rand(10) }).flatten, ["Water", "Just clear and fresh water", "false", "0", "false"].push(currencies.map { |_cu| Random.rand(10) }).flatten]

          respond_to do |format|
            format.csv { send_data(CsvExporter.sample(header, data)) }
          end
        end

        def import
          authorize @station.products.new
          redirect_to(admins_event_station_path(@current_event, @station), alert: t("alerts.import.empty_file")) && return unless params[:file]
          file = params[:file][:data].tempfile.path
          count = 0

          begin
            products = []
            CSV.foreach(file, headers: true, col_sep: ";").with_index do |row, _i|
              products << row.to_hash unless @station.products.find_by(name: row.field('name'))
            end

            currencies = @current_event.currencies
            fields = %w[name description is_alcohol vat hidden]

            products.each do |row|
              prices = row.dup.except(*fields).map { |k, v| [currencies.find_by(type: k)&.id, { 'price' => v.to_f }] if v.present? }.to_h
              @station.products.create!(row.slice(*fields).merge(prices: prices))
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
          params.require(:product).permit(:name, :description, :is_alcohol, :vat, :hidden, prices: {})
        end
      end
    end
  end
end
