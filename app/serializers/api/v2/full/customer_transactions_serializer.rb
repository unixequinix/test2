class Api::V2::Full::CustomerTransactionsSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :phone, :birthdate, :phone, :postcode, :address, :city,
             :country, :gender, :global_refundable_money, :global_money, :locale, :anonymous

  has_many :gtags, serializer: Api::V2::Simple::GtagSerializer
  has_many :tickets, serializer: Api::V2::Simple::TicketSerializer
  has_many :orders, serializer: Api::V2::OrderSerializer
  has_many :transactions, serializer: Api::V2::TransactionSerializer

  def transactions
    object.transactions.credit.status_ok.order(:gtag_counter)
  end
end
