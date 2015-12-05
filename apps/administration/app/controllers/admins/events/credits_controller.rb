class Admins::Events::CreditsController < Admins::Events::BaseController

  def index
    all_credits = @fetcher.credits
    @credits = all_credits
      .where(online_products: { event_id: current_event.id })
      .page(params[:page])
      .includes(:online_product)
    @credits_count = all_credits.count
  end

  def new
    @credit = Credit.new
    @credit.build_online_product
  end

  def create
    @credit = Credit.new(permitted_params)
    if @credit.save
      flash[:notice] = I18n.t('alerts.created')
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
      flash[:notice] = I18n.t('alerts.updated')
      redirect_to admins_event_credits_url
    else
      flash[:error] = @credit.errors.full_messages.join(". ")
      render :edit
    end
  end

  def destroy
    @credit = @fetcher.credits.find(params[:id])
    @credit.destroy!
    flash[:notice] = I18n.t('alerts.destroyed')
    redirect_to admins_event_credits_url
  end

  private

  def permitted_params
    params.require(:credit).permit(online_product_attributes: [:event_id, :name, :description, :price, :min_purchasable, :max_purchasable, :initial_amount, :step])
  end

end
