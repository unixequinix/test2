class Api::V1::Events::CredentialTypesController < Api::V1::Events::BaseController
  def index
    render json: @fetcher.credential_types, each_serializer: Api::V1::CredentialTypeSerializer
  end
end
