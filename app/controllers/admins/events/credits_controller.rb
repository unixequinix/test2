class Admins::Events::CreditsController < Admins::Events::BaseController
  before_action :set_credit

  def update
    authorize @credit
    if @credit.update(permitted_params)
      flash[:notice] = t("alerts.updated")
      redirect_to admins_event_credits_path
    else
      flash.now[:error] = @credit.errors.full_messages.join(". ")
      render :edit
    end
  end

  private

  def set_credit
    @credit = @current_event.credit
    authorize @credit
  end

  def permitted_params
    params.require(:credit).permit(:currency, :value, :id, :name, :description, :initial_amount, :step, :max_purchasable, :min_purchasable)
  end
end
