class PaymentGateway < ApplicationRecord
  belongs_to :event
  store_accessor :data, %i[login password signature]

  GATEWAYS = {
    paypal: { actions: %i[topup refund], config: %i[login password signature] },
    vouchup: { actions: %i[topup refund], config: [] },
    bank_account: { actions: %i[refund], config: [] }
  }.freeze

  validates :name, uniqueness: { scope: :event_id }

  validates :refund_field_a_name, :refund_field_b_name, presence: true, if: (-> { refund? && bank_account? })
  validates :fee, :minimum, numericality: { greater_than_or_equal_to: 0 }, presence: true, if: (-> { refund? })

  validates :login, :password, :signature, presence: true, if: (-> { paypal? })
  validate :extra_fields_format

  enum name: { paypal: 0, redsys: 1, stripe: 2, wirecard: 3, bank_account: 4, mercadopago: 5, vouchup: 6, transferwise: 7, transferwise_direct: 8 }

  scope(:topup, -> { where(topup: true) })
  scope(:refund, -> { where(refund: true) })
  scope(:vouchup, -> { where(name: "vouchup") })
  scope(:bank_account, -> { find_by(name: "bank_account") })
  def actions
    GATEWAYS[name.to_sym][:actions] || []
  end

  def extra_fields_format
    self.extra_fields = extra_fields&.reject(&:empty?)
  end
end
