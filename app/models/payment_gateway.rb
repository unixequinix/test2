class PaymentGateway < ActiveRecord::Base
  belongs_to :event
  store_accessor :data, %i[login password signature public_key token secret_key terminal destination]

  GATEWAYS = YAML.load_file(Rails.root.join('config', 'glownet', 'payment_gateways.yml')).reject! { |k, _v| k.eql?("commons") }

  validates :name, uniqueness: { scope: :event_id }

  validates(:refund_field_a_name, :refund_field_b_name, presence: true, if: -> { refund? && bank_account? })
  validates(:fee, :minimum, numericality: { greater_than_or_equal_to: 0 }, if: -> { refund? })

  validates(:login, :password, :signature, presence: true, if: -> { paypal? || wirecard? })
  validates(:public_key, :token, presence: true, if: -> { mercadopago? })
  validates(:client_id, :client_secret, presence: true, if: -> { wirecard? })
  validates(:login, presence: true, if: -> { stripe? })

  enum name: { paypal: 0, redsys: 1, stripe: 2, wirecard: 3, bank_account: 4, mercadopago: 5, vouchup: 6 }

  scope(:topup, -> { where(topup: true) })
  scope(:refund, -> { where(refund: true) })

  def actions
    GATEWAYS[name] && GATEWAYS[name]["actions"] || []
  end
end
