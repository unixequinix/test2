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

class CredentialTransaction < Transaction
  SUBSCRIPTIONS = {
    encoded_ticket_scan: [:create_ticket,
                          :assign_company_ticket_type],
    ticket_checkin: [:create_ticket_credential_assignment,
                     :create_customer_event_profile,
                     :create_gtag,
                     :create_gtag_credential_assignment,
                     :create_customer_order,
                     :redeem_customer_order,
                     :redeem_gtag],
    gtag_checkin: [:create_ticket_credential_assignment,
                   :create_customer_event_profile,
                   :create_customer_order,
                   :redeem_customer_order,
                   :redeem_gtag],
    order_redemption: [:initialize_balance,
                       :generate_monetray_transaction,
                       :redeem_customer_order],
    accreditation: [:create_gtag_credential_assignment,
                    :create_customer_event_profile,
                    :create_customer_order,
                    :redeem_customer_order],
    encoded_ticket_assignment: [:create_ticket],
    order_created: [:initialize_balance,
                    :generate_monetray_transaction,
                    :redeem_customer_order] }

  def create_ticket; end

  def assign_company_ticket_type; end

  def create_ticket_credential_assignment; end

  def create_customer_event_profile; end

  def create_gtag; end

  def create_gtag_credential_assignment; end

  def create_customer_order; end

  def redeem_customer_order; end

  def redeem_gtag; end

  def initialize_balance; end

  def generate_monetray_transaction; end

end
