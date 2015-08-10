class Customers::GtagRegistrationsController < Customers::BaseController
  before_action :check_event_status!
  before_action :check_has_not_gtag_registration!, only: [:new, :create]

  def new
    @gtag_registration_presenter = GtagRegistrationPresenter.new(current_event: current_event)
  end

  def create
    @gtag_registration_presenter = GtagRegistrationPresenter.new(current_event: current_event)
    gtag = Gtag.find_by(tag_uid: params[:tag_uid].strip.upcase, tag_serial_number: params[:tag_serial_number].strip.upcase)
    if !gtag.nil? && current_customer.assigned_gtag_registration.nil?
      @gtag_registration = GtagRegistration.new(customer_id: current_customer.id, gtag_id: gtag.id)
      if @gtag_registration.save
        flash[:notice] = I18n.t('alerts.created')
        GtagMailer.assigned_email(@gtag_registration, current_event).deliver_later
        redirect_to customer_root_url
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
    @gtag_registration.unassign!
    flash[:notice] = I18n.t('alerts.unassigned')
    GtagMailer.unassigned_email(@gtag_registration, current_event).deliver_later
    redirect_to customer_root_url
  end


  private

  def check_event_status!
    if !current_event.gtag_registration?
      flash.now[:error] = I18n.t('alerts.error')
      redirect_to customer_root_path
    end
  end

  def check_has_not_gtag_registration!
    if !current_customer.assigned_gtag_registration.nil?
      redirect_to customer_root_path, flash: { error: I18n.t('alerts.already_assigned') }
    end
  end
end
