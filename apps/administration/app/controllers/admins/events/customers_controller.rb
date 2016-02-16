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
      :customer_event_profile,
      customer_event_profile: [:ticket_assignments,
                               :active_gtag_assignment,
                               credential_assignments: :credentiable]
    ).find(params[:id])
  end

  def resend_confirmation
    @customer = @fetcher.customers.find(params[:id])
    CustomerMailer.confirmation_instructions_email(@customer).deliver_later
  end

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "Customer".constantize.model_name,
      fetcher: @fetcher.customers,
      search_query: params[:q],
      page: params[:page],
      context: view_context,
      include_for_all_items: [:customer_event_profile,
                              customer_event_profile: [:active_gtag_assignment,
                                                       active_assignments: :credentiable]])
  end
end
