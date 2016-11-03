class Admins::Events::CustomersController < Admins::Events::BaseController
  before_action :set_presenter, only: [:index, :search]

  def index
    respond_to do |format|
      format.html { set_presenter }
      format.csv do
        customers = Customer.query_for_csv(current_event)
        redirect_to(admins_event_customers_path(current_event)) && return if customers.empty?
        send_data(Csv::CsvExporter.to_csv(customers))
      end
    end
  end

  def search
    render :index
  end

  # TODO: Cleanup this shit.
  def show
    @customer = current_event.customers.find(params[:id])
  end

  def reset_password
    @customer = current_event.customers.find(params[:id])
    @customer.update(password: "123456", password_confirmation: "123456")
    redirect_to admins_event_customer_path(current_event, @customer)
  end

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "Customer".constantize.model_name,
      fetcher: current_event.customers,
      search_query: params[:q],
      page: params[:page],
      context: view_context,
      include_for_all_items: [:profile, profile: [:tickets, :active_gtag, :payment_gateway_customers]]
    )
  end
end
