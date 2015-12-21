class Admins::Events::CustomersController < Admins::Events::BaseController
  def index
    set_presenter
  end

  def search
    index
    render :index
  end

  def show
    @customer = @fetcher.customers.with_deleted.includes(:customer_event_profile, customer_event_profile: [:credential_assignments_tickets_assigned, :credential_assignments_gtag_assigned ]).find(params[:id])
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
      include_for_all_items: [:customer_event_profile, customer_event_profile:
        [:credential_assignments_tickets_assigned, :credential_assignments_gtag_assigned,
          credential_assignments_assigned: :credentiable
        ]
      ]
    )
  end
end
