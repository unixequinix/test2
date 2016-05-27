class Admins::Events::AccessesController < Admins::Events::BaseController
  def index
    @accesses = @fetcher.accesses
                        .includes(:entitlement, catalog_item: :credential_type)
                        .page(params[:page])
  end

  def new
    @access = Access.new
    @access.build_catalog_item
    @access.build_entitlement
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
      flash.now[:error] = I18n.t("errors.messages.catalog_item_dependent")
      binding.pry
      set_presenter
      render :index
    end
  end

  def create_credential
    access = @fetcher.accesses.find(params[:id])
    access.catalog_item.create_credential_type if access.catalog_item.credential_type.blank?
    redirect_to admins_event_accesses_url
  end

  def destroy_credential
    access = @fetcher.accesses.find(params[:id])
    access.catalog_item.credential_type.destroy if access.catalog_item.credential_type.present?
    redirect_to admins_event_accesses_url
  end

  private

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "Access".constantize.model_name,
      fetcher: @fetcher.accesses,
      search_query: params[:q],
      page: params[:page],
      include_for_all_items: [:entitlement, catalog_item: :credential_type],
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
                                   ],
                                   entitlement_attributes: [
                                     :id,
                                     :memory_length,
                                     :mode,
                                     :event_id])
  end
end
