module Companies
  module Api
    module V1
      class GtagSerializer < Companies::Api::V1::BaseSerializer
        attributes :id, :tag_uid
      end
    end
  end
end
