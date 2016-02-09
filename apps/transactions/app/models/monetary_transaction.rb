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
#  amount                    :float            default(0.0)
#  status_code               :string
#  status_message            :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class MonetaryTransaction < Transaction
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
