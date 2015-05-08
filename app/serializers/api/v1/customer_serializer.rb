module Api
  module V1
    class CustomerSerializer < Api::V1::BaseSerializer
      attributes :email, :name, :surname, :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip

      def current_sign_in_ip
        object.current_sign_in_ip.to_s
      end

      def last_sign_in_ip
        object.last_sign_in_ip.to_s
      end
    end
  end
end
