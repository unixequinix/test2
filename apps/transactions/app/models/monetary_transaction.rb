# == Schema Information
#
# Table name: transactions
#
#  id                        :integer          not null, primary key
#  type                      :string           not null
#  event_id                  :integer
#  transaction_type          :string
#  device_created_at         :datetime
#  ticket_id                 :integer
#  customer_tag_uid          :string
#  operator_tag_uid          :string
#  station_id                :integer
#  device_id                 :integer
#  device_uid                :integer
#  preevent_product_id       :integer
#  customer_event_profile_id :integer
#  payment_method            :string
#  status_code               :string
#  status_message            :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  credits                   :integer
#  credits_refundable        :integer
#  value_credit              :integer
#  payment_gateway           :string
#  final_balance             :integer
#  final_refundable_balance  :integer
#  access_entitlement_id     :integer
#  direction                 :integer
#  access_entitlement_value  :integer
#

class MonetaryTransaction < ActiveRecord::Base
  belongs_to :event
  belongs_to :station
  belongs_to :device
  belongs_to :customer_event_profile

  SUBSCRIPTIONS = {
    topup: :rise_balance,
    fee: :decrease_balance,
    refund: :decrease_balance,
    sale: [:decrease_balance, :create_sales],
    sale_refund: :rise_balance,
    credential_topup: :rise_balance,
    credential_refund: :decrease_balance,
    online_topup: :rise_balance,
    auto_topup: :rise_balance,
    online_refund: :decrease_balance }

  def decrease_balance; end

  def rise_balance; end

  def create_sales; end
end
