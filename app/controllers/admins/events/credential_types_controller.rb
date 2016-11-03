class Admins::Events::CredentialTypesController < Admins::Events::BaseController
  before_action :set_credential_type, only: [:edit, :update, :destroy]
  def index
    set_presenter
  end

  def new
    @credential_type = CredentialType.new
    @catalog_items_collection = current_event.catalog_items.only_credentiables
  end

  def create
    @credential_type = CredentialType.new(permitted_params)
    if @credential_type.save
      flash[:notice] = I18n.t("alerts.created")
      redirect_to admins_event_credential_types_url
    else
      @catalog_items_collection = current_event.catalog_items.only_credentiables
      flash.now[:error] = @credential_type.errors.full_messages.join(". ")
      render :new
    end
  end

  def edit
    @catalog_items_collection = current_event.catalog_items.only_credentiables
  end

  def update
    if @credential_type.update(permitted_params)
      flash[:notice] = I18n.t("alerts.updated")
      redirect_to admins_event_credential_types_url
    else
      @catalog_items_collection = current_event.catalog_items.only_credentiables
      flash.now[:error] = @credential_type.errors.full_messages.join(". ")
      render :edit
    end
  end

  def destroy
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

  def set_credential_type
    @credential_type = current_event.credential_types.find(params[:id])
  end

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "CredentialType".constantize.model_name,
      fetcher: current_event.credential_types,
      search_query: params[:q],
      page: params[:page],
      include_for_all_items: [:catalog_item],
      context: view_context
    )
  end

  def permitted_params
    params.require(:credential_type).permit(:id, :catalog_item_id)
  end
end