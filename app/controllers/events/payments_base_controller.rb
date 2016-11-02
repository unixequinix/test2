class Events::PaymentsBaseController < Events::BaseController
  def success
    @admissions = current_profile.tickets
    @dashboard = Dashboard.new(current_profile, view_context)
    @presenter = CreditsPresenter.new(@dashboard, view_context)
  end

  def error
    @admissions = current_profile.tickets
    @dashboard = Dashboard.new(current_profile, view_context)
    @presenter = CreditsPresenter.new(@dashboard, view_context)
    @error = params[:error]
  end
end
