class Events::PaymentsBaseController < Events::BaseController
  def success
    @admissions = current_profile.active_tickets_assignment
    @dashboard = Dashboard.new(current_profile, view_context)
    @presenter = CreditsPresenter.new(@dashboard, view_context)
  end

  def error
    @admissions = current_profile.active_tickets_assignment
    @dashboard = Dashboard.new(current_profile, view_context)
    @presenter = CreditsPresenter.new(@dashboard, view_context)
  end
end
