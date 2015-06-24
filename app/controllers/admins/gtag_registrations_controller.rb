class Admins::GtagRegistrationsController < Admins::BaseController

  def new
    @gtag_registration = GtagRegistration.new
    @customer = Customer.find(params[:customer_id])
  end

  def create
    gtag = Gtag.find_by(tag_uid: params[:tag_uid].upcase, tag_serial_number: params[:tag_serial_number].upcase)
    @customer = Customer.find(params[:customer_id])
    if !gtag.nil?
      @gtag_registration = GtagRegistration.new(customer_id: params[:customer_id], gtag_id: gtag.id)
      if @gtag_registration.save
        flash[:notice] = I18n.t('alerts.created')
        GtagMailer.assigned_email(@gtag_registration, current_event).deliver_later
        redirect_to admins_customer_url(@customer)
      else
        flash[:error] = @gtag_registration.errors.full_messages.join(". ")
        render :new
      end
    else
      flash[:error] = I18n.t('alerts.gtag')
      render :new
    end
  end

  def destroy
    @gtag_registration = GtagRegistration.find(params[:id])
    @customer = @gtag_registration.customer
    @gtag_registration.unassign!
    flash[:notice] = I18n.t('alerts.unassigned')
    GtagMailer.unassigned_email(@gtag_registration, current_event).deliver_later
    redirect_to admins_customer_url(@customer)
  end
end
