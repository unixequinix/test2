module Api
  module V1
    class AdmissionSerializer < Api::V1::BaseSerializer
      attributes :customer

      def customer
        object.customer.name
      end

    end
  end
end
