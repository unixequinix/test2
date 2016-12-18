class Admins::Events::CreditsController < Admins::Events::BaseController
  before_action :set_credit, except: [:new, :create]

  def update
    if @credit.update(permitted_params)
      flash[:notice] = I18n.t("alerts.updated")
      redirect_to admins_event_credits_url
    else
      flash.now[:error] = @credit.errors.full_messages.join(". ")
      render :edit
    end
  end

  private

  def set_credit
    @credit = @current_event.credit
  end

  def permitted_params
    params.require(:credit).permit(:currency,
                                   :value,
                                   :id,
                                   :event_id,
                                   :name,
                                   :description,
                                   :initial_amount,
                                   :step,
                                   :max_purchasable,
                                   :min_purchasable)
  end
end
