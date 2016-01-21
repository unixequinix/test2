class Admins::Events::CreditsController < Admins::Events::BaseController
  def index
    set_presenter
  end

  def new
    @credit = Credit.new
    @credit.build_preevent_item
  end

  def create
    @credit = Credit.new(permitted_params)
    if @credit.save
      flash[:notice] = I18n.t("alerts.created")
      redirect_to admins_event_credits_url
    else
      flash[:error] = @credit.errors.full_messages.join(". ")
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
      flash[:error] = @credit.errors.full_messages.join(". ")
      render :edit
    end
  end

  def destroy
    @credit = @fetcher.credits.find(params[:id])
    @credit.destroy!
    flash[:notice] = I18n.t("alerts.destroyed")
    redirect_to admins_event_credits_url
  end

  private

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "Credit".constantize.model_name,
      fetcher: @fetcher.credits,
      search_query: params[:q],
      page: params[:page],
      include_for_all_items: [:preevent_item],
      context: view_context
    )
  end

  def permitted_params
    params.require(:credit).permit(:standard,
                                   preevent_item_attributes: [
                                     :event_id,
                                     :name,
                                     :description,
                                     :price,
                                     :min_purchasable,
                                     :max_purchasable,
                                     :initial_amount,
                                     :step
                                   ]
                                  )
  end
end
