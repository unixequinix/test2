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

    tag = @customer.profile.active_gtag_assignment&.credentiable&.tag_uid
    @credit_transactions = CreditTransaction.where(event: current_event, customer_tag_uid: tag)
                                            .order(device_created_at: :desc)
                                            .includes(:station)
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
                                        active_assignments: :credentiable]])
  end
end
