class Customers::RfidTagRegistrationsController < Customers::BaseController

  def new
    @rfid_tag_registration = RfidTagRegistration.new
  end

  def create
    rfid_tag = RfidTag.find_by(number: params[:rfid_tag_number])
    if !rfid_tag.nil?
      @rfid_tag_registration = RfidTagRegistration.new(customer_id: current_customer.id, rfid_tag_id: rfid_tag.id)
      if @rfid_tag_registration.save
        flash[:notice] = "created TODO"
        redirect_to customer_root_url
      else
        flash[:error] = @rfid_tag_registration.errors.full_messages.join(". ")
        render :new
      end
    else
      flash[:error] = "This is not a valid rfid_tag TODO"
      render :new
    end
  end

  def destroy
    @rfid_tag_registration = RfidTagRegistration.find(params[:id])
    @rfid_tag_registration.unassign!
    flash[:notice] = "unassigned TODO"
    redirect_to customer_root_url
  end

end
