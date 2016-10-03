class Admins::Events::CustomersController < Admins::Events::BaseController
  before_filter :set_presenter, only: [:index, :search]

  def index
    respond_to do |format|
      format.html { set_presenter }
      format.csv { send_data(Csv::CsvExporter.to_csv(Customer.selected_data(current_event))) }
    end
  end

  def search
    render :index
  end

  # TODO: Cleanup this shit.
  def show
    @customer = current_event.customers.includes(
      :profile,
      profile: [:ticket_assignments,
                :active_gtag_assignment,
                :active_tickets_assignment,
                :active_gtag_assignment,
                credit_transactions: :station,
                money_transactions: :station,
                access_transactions: :station,
                credential_transactions: :station,
                order_transactions: :station,
                credential_assignments: :credentiable,
                customer_orders: [:catalog_item, :online_order]]
    ).find(params[:id])

    @credit_transactions = @customer.profile&.credit_transactions
  end

  def reset_password
    @customer = current_event.customers.find(params[:id])
    @customer.update(encrypted_password: Authentication::Encryptor.digest("123456"))
    redirect_to admins_event_customer_path(current_event, @customer)
  end

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "Customer".constantize.model_name,
      fetcher: current_event.customers,
      search_query: params[:q],
      page: params[:page],
      context: view_context,
      include_for_all_items: [:profile,
                              profile: [:active_tickets_assignment,
                                        :active_gtag_assignment,
                                        :payment_gateway_customers,
                                        active_assignments: :credentiable]]
    )
  end
end
