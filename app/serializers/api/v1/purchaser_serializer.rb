module Api
  module V1
    class PurchaserSerializer < Api::V1::BaseSerializer
      attributes :name, :surname, :email
    end
  end
end
