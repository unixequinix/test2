module Api
  module V1
    class UserFlagSerializer < ActiveModel::Serializer
      attributes :id, :name
    end
  end
end
