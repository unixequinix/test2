module Api::V2
  class Full::CustomerSerializer < ActiveModel::Serializer
    attributes :id, :first_name, :last_name, :email, :phone, :birthdate, :phone, :postcode, :address,
               :city, :country, :gender, :global_refundable_money, :global_money, :locale, :anonymous

    has_many :gtags, serializer: Simple::GtagSerializer
    has_many :tickets, serializer: Simple::TicketSerializer
    has_many :orders, serializer: OrderSerializer
  end
end
