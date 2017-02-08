# == Schema Information
#
# Table name: payment_gateways
#
#  data                :jsonb            not null
#  name                :integer
#  refund              :boolean
#  refund_field_a_name :string           default("iban")
#  refund_field_b_name :string           default("swift")
#  topup               :boolean
#
# Indexes
#
#  index_payment_gateways_on_event_id  (event_id)
#
# Foreign Keys
#
#  fk_rails_9c9a24f555  (event_id => events.id)
#

class PaymentGateway < ActiveRecord::Base
  belongs_to :event
  store_accessor :data, [:fee, :minimum, :login, :password, :secret_key, :client_id, :client_secret, :public_key, :token, :signature, :terminal, :currency, :destination] # rubocop:disable Metrics/LineLength

  GATEWAYS = YAML.load_file(Rails.root.join('config', 'glownet', 'payment_gateways.yml')).reject! { |k, _v| k.eql?("commons") }

  validates :name, uniqueness: { scope: :event_id }

  validates :refund_field_a_name, :refund_field_b_name, presence: true, if: -> { refund? }
  validates :fee, :minimum, numericality: { greater_than_or_equal_to: 0 }, if: -> { refund? }

  validates :login, :password, :signature, presence: true, if: -> { paypal? || wirecard? }
  validates :login, :secret_key, :terminal, presence: true, if: -> { redsys? }
  validates :login, presence: true, if: -> { stripe? }

  enum name: { paypal: 0, redsys: 1, stripe: 2, wirecard: 3, bank_account: 4, mercadopago: 5 }

  scope :topup, -> { where(topup: true) }
  scope :refund, -> { where(refund: true) }

  scope :mercadopago, -> { find_by(name: "mercadopago") }
  scope :paypal, -> { find_by(name: "paypal") }
  scope :redsys, -> { find_by(name: "redsys") }
  scope :stripe, -> { find_by(name: "stripe") }
  scope :wirecard, -> { find_by(name: "wirecard") }
  scope :bank_account, -> { find_by(name: "bank_account") }
end
