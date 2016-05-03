class Admins::Events::ProfilesController < Admins::Events::BaseController
  def index
    set_presenter
  end

  def search
    index
    render :index
  end

  def show
    @profile =
      @fetcher.profiles.with_deleted
      .includes(:active_tickets_assignment,
                :active_gtag_assignment,
                credential_assignments: :credentiable,
                customer_orders: [:catalog_item, :online_order])
      .find(params[:id])
  end

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "Profile".constantize.model_name,
      fetcher: @fetcher.profiles,
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
