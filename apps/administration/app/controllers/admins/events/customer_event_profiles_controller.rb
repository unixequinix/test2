class Admins::Events::CustomerEventProfilesController < Admins::Events::BaseController
  def index
    set_presenter
  end

  def search
    index
    render :index
  end

  def show
    @customer_event_profile =
      @fetcher.customer_event_profiles.with_deleted
                                      .includes(:active_tickets_assignment,
                                                :active_gtag_assignment,
                                                credential_assignments: :credentiable)
                                      .find(params[:id])
  end

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: 'CustomerEventProfile'.constantize.model_name,
      fetcher: @fetcher.customer_event_profiles,
      search_query: params[:q],
      page: params[:page],
      context: view_context,
      include_for_all_items: [
        :customer,
        :active_tickets_assignment,
        :active_gtag_assignment,
        credential_assignments: :credentiable
      ]
    )
  end
end
