class Admins::Events::CustomersController < Admins::Events::BaseController
  def index
    set_presenter
  end

  def search
    index
    render :index
  end

  def show
<<<<<<< HEAD
    @customer = @fetcher.customers.with_deleted.includes( :customer_event_profile, customer_event_profile: [:credential_assignments_tickets_assigned, :credential_assignments_gtag_assigned ]).find(params[:id])
#TODO - Check if the query is enough or we shoul add the last part: gtag_registrations...
=begin
    @customer = @fetcher.customers.with_deleted.includes(:customer_event_profile, customer_event_profile: [:assigned_admissions, :assigned_gtag_registration, admissions: :ticket, gtag_registrations: [:gtag, gtag: :gtag_credit_log]]).find(params[:id])
=end

=======
    @customer = @fetcher.customers.with_deleted.includes(:customer_event_profile, customer_event_profile: [:credential_assignments_tickets_assigned, :credential_assignments_gtag_assigned ]).find(params[:id])
>>>>>>> f0b9f1335165ef15ad4d1369dff8e6cd2e944746
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
