class Admins::Events::SettingsController < Admins::Events::BaseController
  def show
    @versions = @current_event.versions.reorder(created_at: :desc).page(params[:page])
    authorize @current_event
  end
end
