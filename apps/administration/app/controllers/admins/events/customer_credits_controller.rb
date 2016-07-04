class Admins::Events::CustomerCreditsController < Admins::Events::BaseController
  def update
    @cc = CustomerCredit.find(params[:id])
    respond_to do |format|
      if @cc.update(permitted_params)
        format.json { render status: :ok, json: @cc }
      else
        format.json { render status: :unprocessable_entity, json: @cc }
      end
    end
  end

  private

  def permitted_params
    params.require(:customer_credit)
          .permit(:amount, :refundable_amount, :final_balance, :final_refundable_balance, :gtag_counter, :online_counter)
  end
end
