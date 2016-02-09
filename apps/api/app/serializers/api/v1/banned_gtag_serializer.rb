module Api
  module V1
    class BannedGtagSerializer < Api::V1::BaseSerializer
      attributes :id, :tag_uid
    end
  end
end
