module Api
  module V1
    class OnlineProductSerializer < Api::V1::BaseSerializer
      attributes :name, :description, :price
    end
  end
end
