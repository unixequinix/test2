class Admins::Events::CustomersController < Admins::Events::BaseController
  def index
    set_presenter
  end

  def search
    index
    render :index
  end

  def show
    @customer = @fetcher.customers.with_deleted.includes(
      :profile,
      profile: [:ticket_assignments,
                :active_gtag_assignment,
                credential_assignments: :credentiable,
                customer_orders: [:catalog_item, :online_order]]
    ).find(params[:id])

    tag_uid = @customer.profile&.active_gtag_assignment&.credentiable&.tag_uid
    @credit_transactions = CreditTransaction.with_event(current_event)
                                            .with_customer_tag(tag_uid)
                                            .reorder(gtag_counter: :desc)
                                            .includes(:station)
  end

  def reset_password
    @customer = @fetcher.customers.find(params[:id])
    @customer.update(encrypted_password: Authentication::Encryptor.digest("123456"))
    redirect_to admins_event_customer_path(current_event, @customer)
  end

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "Customer".constantize.model_name,
      fetcher: @fetcher.customers,
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
