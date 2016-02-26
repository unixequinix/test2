class Admins::Events::CredentialTypesController < Admins::Events::BaseController
  def index
    set_presenter
  end

  def new
    @credential_type = CredentialType.new
    @catalog_items_collection = @fetcher.catalog_items.where(catalogable_type: "Access")
  end

  def create
    @credential_type = CredentialType.new(permitted_params)
    if @credential_type.save
      flash[:notice] = I18n.t("alerts.created")
      redirect_to admins_event_credential_types_url
    else
      @catalog_items_collection = @fetcher.catalog_items.where(catalogable_type: "Access")
      flash.now[:error] = @credential_type.errors.full_messages.join(". ")
      render :new
    end
  end

  def edit
    @credential_type = @fetcher.credential_types.find(params[:id])
    @catalog_items_collection = @fetcher.catalog_items.where(catalogable_type: "Access")
  end

  def update
    @credential_type = @fetcher.credential_types.find(params[:id])
    if @credential_type.update(permitted_params)
      flash[:notice] = I18n.t("alerts.updated")
      redirect_to admins_event_credential_types_url
    else
      @catalog_items_collection = @fetcher.catalog_items.where(catalogable_type: "Access")
      flash.now[:error] = @credential_type.errors.full_messages.join(". ")
      render :edit
    end
  end

  def destroy
    @credential_type = @fetcher.credential_types.find(params[:id])
    if @credential_type.destroy
      flash[:notice] = I18n.t("alerts.destroyed")
      redirect_to admins_event_credential_types_url
    else
      flash.now[:error] = I18n.t("errors.messages.catalog_item_dependent")
      set_presenter
      render :index
    end
  end

  private

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "CredentialType".constantize.model_name,
      fetcher: @fetcher.credential_types,
      search_query: params[:q],
      page: params[:page],
      include_for_all_items: [:catalog_item],
      context: view_context
    )
  end

  def permitted_params
    params.require(:credential_type).permit(:catalog_item_id)
  end
end
