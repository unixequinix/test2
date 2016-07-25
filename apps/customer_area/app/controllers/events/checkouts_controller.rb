class Events::CheckoutsController < Events::BaseController
  before_action :check_top_ups_is_active!
  before_action :check_has_ticket!

  def new
    @presenter = CheckoutsPresenter.new(current_event, current_profile)
  end

  def create # rubocop:disable Metrics/AbcSize
    @presenter = CheckoutsPresenter.new(current_event, current_profile)
    @checkout_form = CheckoutForm.new(current_profile)
    amount = params[:checkout_form][:catalog_items].values.map(&:to_i).sum

    if !amount.zero? && @checkout_form.submit(params[:checkout_form], @presenter.catalog_items)
      flash[:notice] = I18n.t("alerts.created")
      redirect_to event_order_url(current_event, @checkout_form.order)
    else
      errors = @checkout_form.order.errors.full_messages.join(". ")
      errors = I18n.t("alerts.checkout", limit: 500) if !@checkout_form.order.order_items.present?
      flash.now[:error] = errors || ""
      render :new
    end
  end
end
