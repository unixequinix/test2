class Api::V1::Events::CredentialTypesController < Api::V1::Events::BaseController
  def index
    render_entities("credential_type")
  end
end
