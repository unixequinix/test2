# == Schema Information
#
# Table name: payment_gateways
#
#  created_at :datetime         not null
#  data       :json
#  gateway    :string
#  refund     :boolean
#  topup      :boolean
#  updated_at :datetime         not null
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

  GATEWAYS = YAML.load_file(Rails.root.join('config', 'glownet', 'payment_gateways.yml'))
                 .reject! { |k, _v| k.eql?("commons") }

  validates :gateway, uniqueness: { scope: :event_id }

  scope :topup, -> { where(topup: true) }
  scope :refund, -> { where(refund: true) }
  scope :paypal, -> { find_by(gateway: "paypal") }
  scope :redsys, -> { find_by(gateway: "redsys") }
  scope :stripe, -> { find_by(gateway: "stripe") }
  scope :wirecard, -> { find_by(gateway: "wirecard") }
  scope :bank_account, -> { find_by(gateway: "bank_account") }

  def redirected?
    GATEWAYS[gateway]["type"].eql?("redirected")
  end

  private

  def data_present
    fields = GATEWAYS[gateway][:config]
    fields.each do |field|
      next if data[field].present?
      errors[field] = I18n.t("errors.messages.blank")
    end
  end
end
