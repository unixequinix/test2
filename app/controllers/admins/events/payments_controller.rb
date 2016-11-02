class Admins::Events::PaymentsController < Admins::Events::BaseController
  before_action :set_presenter, only: [:index, :search]

  def index
    @counts = current_event.payments.pluck(:amount, :transaction_type).group_by(&:last)
    @counts = @counts.map { |type, payments| [type, payments.sum { |amount, _| amount }.to_f] }

    respond_to do |format|
      format.html
      format.csv { send_data Csv::CsvExporter.to_csv(current_event.payments) }
    end
  end

  def search
    render :index
  end

  def show
    @payment = current_event.payments.find(params[:id])
  end

  private

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "Payment".constantize.model_name,
      fetcher: current_event.payments,
      search_query: params[:q],
      page: params[:page],
      include_for_all_items: [:order],
      context: view_context
    )
  end
end
