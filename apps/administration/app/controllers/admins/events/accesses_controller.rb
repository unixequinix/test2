class Admins::Events::AccessesController < Admins::Events::BaseController
  def index
    set_presenter
  end

  def new
    @access = Access.new
    @access.build_catalog_item
  end

  def create
    @access = Access.new(permitted_params)
    if @access.save
      flash[:notice] = I18n.t("alerts.created")
      redirect_to admins_event_accesses_url
    else
      flash.now[:error] = @access.errors.full_messages.join(". ")
      render :new
    end
  end

  def edit
    @access = @fetcher.accesses.find(params[:id])
  end

  def update
    @access = @fetcher.accesses.find(params[:id])
    if @access.update(permitted_params)
      flash[:notice] = I18n.t("alerts.updated")
      redirect_to admins_event_accesses_url
    else
      flash.now[:error] = @access.errors.full_messages.join(". ")
      render :edit
    end
  end

  def destroy
    @access = @fetcher.accesses.find(params[:id])
    if @access.destroy
      flash[:notice] = I18n.t("alerts.destroyed")
      redirect_to admins_event_accesses_url
    else
      flash.now[:error] = I18n.t("errors.messages.preevent_item_dependent")
      set_presenter
      render :index
    end
  end

  private

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "Access".constantize.model_name,
      fetcher: @fetcher.accesses,
      search_query: params[:q],
      page: params[:page],
      include_for_all_items: [:catalog_item],
      context: view_context
    )
  end

  def permitted_params
    params.require(:access).permit(catalog_item_attributes: [
                                                             :id,
                                                             :event_id,
                                                             :name,
                                                             :description,
                                                             :initial_amount,
                                                             :step,
                                                             :max_purchasable,
                                                             :min_purchasable
                                                            ]
                                                          )
  end
end
