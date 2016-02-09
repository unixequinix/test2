module Api
  module V1
    class CustomerEventProfileSerializer < Api::V1::BaseSerializer
      attributes :id, :name, :surname, :email, :orders
      has_many :credential_assignments, root: :credentials,
                                        serializer: Api::V1::CredentialAssignmentSerializer

      def name
        object.customer.name
      end

      def surname
        object.customer.surname
      end

      def email
        object.customer.email
      end

      # TODO: Use real values
      def orders
        [{ gtag_version: 1, products: [21, 24, 65] },
         { gtag_version: 2, products: [15, 52, 32] }]
      end
    end
  end
end
