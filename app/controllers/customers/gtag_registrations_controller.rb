class Customers::GtagRegistrationsController < Customers::BaseController

  def new
    @gtag_registration = GtagRegistration.new
  end

  def create
    gtag = Gtag.find_by(tag_uid: params[:tag_uid], tag_serial_number: params[:tag_serial_number])
    if !gtag.nil?
      @gtag_registration = GtagRegistration.new(customer_id: current_customer.id, gtag_id: gtag.id)
      if @gtag_registration.save
        flash[:notice] = "created TODO"
        redirect_to customer_root_url
      else
        flash[:error] = @gtag_registration.errors.full_messages.join(". ")
        render :new
      end
    else
      flash[:error] = "This is not a valid wristband TODO"
      render :new
    end
  end

  def destroy
    @gtag_registration = GtagRegistration.find(params[:id])
    @gtag_registration.unassign!
    flash[:notice] = "unassigned TODO"
    redirect_to customer_root_url
  end

end
