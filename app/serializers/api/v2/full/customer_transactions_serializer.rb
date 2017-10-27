module Api::V2
  class Full::CustomerTransactionsSerializer < ActiveModel::Serializer
    attributes :id, :first_name, :last_name, :email, :phone, :birthdate, :phone, :postcode, :address, :city,
               :country, :gender, :global_refundable_money, :global_money, :locale, :anonymous

    has_many :gtags, serializer: Simple::GtagSerializer
    has_many :tickets, serializer: Simple::TicketSerializer
    has_many :orders, serializer: OrderSerializer
    has_many :transactions, serializer: TransactionSerializer

    def transactions
      object.transactions.credit.status_ok.order(:gtag_counter)
    end
  end
end
