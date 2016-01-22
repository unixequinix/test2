class Events::CheckoutsController < Events::BaseController
  before_action :check_top_ups_is_active!
  before_action :check_has_ticket!

  def new
    @checkout_presenter = CheckoutsPresenter.new(current_event)
  end

  def create
    @checkout_presenter = CheckoutsPresenter.new(current_event)
    @checkout_form = CheckoutForm.new(current_customer_event_profile)

    if @checkout_form.submit(params[:checkout_form], @checkout_presenter.preevent_products)
      flash[:notice] = I18n.t("alerts.created")
      redirect_to event_order_url(current_event, @checkout_form.order)
    else
      flash[:error] = I18n.t("alerts.checkout", limit: 500)
      render :new
    end
  end
end
