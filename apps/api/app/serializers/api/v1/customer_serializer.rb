module Api
  module V1
    class CustomerSerializer < Api::V1::BaseSerializer
      attributes :id, :email, :name, :surname, :created_at, :sign_in_count, :confirmed

      def confirmed
        object.confirmed_at?
      end
    end
  end
end
