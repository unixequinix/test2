class Admins::CustomersController < Admins::BaseController

  def index
    @q = Customer.search(params[:q])
    @customers = @q.result(distinct: true).page(params[:page]).includes(:assigned_admission)
  end

  def search
    index
    render :index
  end

  def show
    @customer = Customer.find(params[:id])
  end

  def resend_confirmation
    Devise::Mailer.confirmation_instructions(params[:id]).deliver_later
    flash[:notice] = I18n.t('alerts.resend')
    redirect_to admins_customers_url
  end

end
