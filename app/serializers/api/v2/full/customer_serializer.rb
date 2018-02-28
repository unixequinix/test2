module Api::V2
  class Full::CustomerSerializer < ActiveModel::Serializer
    attributes :id, :first_name, :last_name, :email, :phone, :birthdate, :phone, :postcode, :address, :city, :country, :gender,
               :virtual_money, :money, :global_refundable_money, :locale, :anonymous, :refundable

    has_many :gtags, serializer: Simple::GtagSerializer
    has_many :tickets, serializer: Simple::TicketSerializer
    has_many :orders, serializer: OrderSerializer

    def refundable
      object.valid_balance? && !object.active_gtag&.banned?
    end

    def global_refundable_money
      object.money
    end
  end
end
