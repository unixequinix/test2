class Api::V2::Full::CustomerSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :phone, :birthdate, :phone, :postcode, :address,
             :city, :country, :gender, :global_refundable_money, :global_money, :locale, :anonymous

  has_many :gtags, serializer: Api::V2::Simple::GtagSerializer
  has_many :tickets, serializer: Api::V2::Simple::TicketSerializer
  has_many :orders, serializer: Api::V2::OrderSerializer
end
