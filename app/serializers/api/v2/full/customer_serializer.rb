class Api::V2::Full::CustomerSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :phone, :birthdate, :phone, :postcode, :address, :city, :country, :gender, :global_refundable_money, :global_money, :locale, :anonymous # rubocop:disable Metrics/LineLength

  has_many :gtags
  has_many :tickets
  has_many :orders
end
