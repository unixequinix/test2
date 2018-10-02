class Events::GtagAssignmentsController < Events::EventsController
  before_action :check_has_not_gtag!, only: %i[new create]

  def new
    @gtag = @current_event.gtags.new
  end

  def create
    @code = permitted_params[:reference].strip
    @gtag = @current_event.gtags.find_or_initialize_by(tag_uid: @code)
    render(:new) && return unless @gtag.validate_assignation

    @gtag.assign_customer(@current_customer, @current_customer)
    @gtag.make_active!

    redirect_to event_path(@current_event), notice: t("credentials.assigned", item: "Tag")
  end

  private

  def check_has_not_gtag!
    return if @current_customer.active_gtag.nil?

    redirect_to event_path(@current_event), flash: { error: t("credentials.already_assigned", item: "Tag") }
  end

  def permitted_params
    params.require(:gtag).permit(:reference)
  end
end
