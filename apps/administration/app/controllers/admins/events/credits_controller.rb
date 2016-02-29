class Admins::Events::CreditsController < Admins::Events::BaseController
  def index
    set_presenter
  end

  def new
    @credit = Credit.new
    @credit.build_catalog_item
  end

  def create
    @credit = Credit.new(permitted_params)
    if @credit.save
      flash[:notice] = I18n.t("alerts.created")
      redirect_to admins_event_credits_url
    else
      flash.now[:error] = @credit.errors.full_messages.join(". ")
      render :new
    end
  end

  def edit
    @credit = @fetcher.credits.find(params[:id])
  end

  def update
    @credit = @fetcher.credits.find(params[:id])
    if @credit.update(permitted_params)
      flash[:notice] = I18n.t("alerts.updated")
      redirect_to admins_event_credits_url
    else
      flash.now[:error] = @credit.errors.full_messages.join(". ")
      render :edit
    end
  end

  def destroy
    @credit = @fetcher.credits.find(params[:id])
    if @credit.destroy
      flash[:notice] = I18n.t("alerts.destroyed")
      redirect_to admins_event_credits_url
    else
      flash.now[:error] = I18n.t("errors.messages.catalog_item_dependent")
      set_presenter
      render :index
    end
  end

  def create_credential
    credits = @fetcher.credits.find(params[:id])
    credits.catalog_item.create_credential_type if credits.catalog_item.credential_type.blank?
    redirect_to admins_event_credits_url
  end

  def destroy_credential
    credits = @fetcher.credits.find(params[:id])
    credits.catalog_item.credential_type.destroy if credits.catalog_item.credential_type.present?
    redirect_to admins_event_credits_url
  end

  private

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "Credit".constantize.model_name,
      fetcher: @fetcher.credits,
      search_query: params[:q],
      page: params[:page],
      include_for_all_items: [:catalog_item],
      context: view_context
    )
  end

  def permitted_params
    params.require(:credit).permit(:standard,
                                   :currency,
                                   :value,
                                   catalog_item_attributes: [
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
