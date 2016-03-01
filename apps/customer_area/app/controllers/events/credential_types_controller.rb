class Events::CredentialTypesController < Events::BaseController
  def show
    assignment = CredentialAssignment.find_by(id: params[:id])
    @presenter = CredentialTypesPresenter.new(assignment, view_context)
  end
end
