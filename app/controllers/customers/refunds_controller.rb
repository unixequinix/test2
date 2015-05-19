class Customers::RefundsController < Customers::BaseController

  def new
    @refund = Refund.new
    @refund.build_bank_account unless current_customer.bank_account
  end

  def create
    @refund = Refund.new(permitted_params)
    if @refund.save
      flash[:notice] = I18n.t('alerts.created')
      redirect_to customer_root_url
    else
      flash[:error] = @refund.errors.full_messages.join(". ")
      render :new
    end
  end

  def edit
    @refund = Refund.find(params[:id])
    @refund.build_bank_account unless current_customer.bank_account
  end

  def update
    @refund = Refund.find(params[:id])
    if @refund.update(permitted_params)
      flash[:notice] = I18n.t('alerts.updated')
      redirect_to customer_root_url
    else
      flash[:error] = @refund.errors.full_messages.join(". ")
      render :edit
    end
  end

  private

  def permitted_params
    params.require(:refund).permit(:customer_id, :gtag_id, bank_account_attributes: [:id, :customer_id, :number])
  end

end
