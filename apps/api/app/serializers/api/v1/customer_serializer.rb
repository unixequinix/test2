module Api
  module V1
    class CustomerSerializer < Api::V1::BaseSerializer
      attributes :id, :email, :name, :surname
    end
  end
end
