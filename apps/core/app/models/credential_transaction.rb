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
    encoded_ticket_scan: :create_ticket,
    ticket_checkin: [:create_customer_event_profile,
                     :create_ticket_credential_assignment,
                     :create_gtag,
                     :create_gtag_credential_assignment,
                     :create_customer_order,
                     :redeem_customer_order,
                     :redeem_ticket],
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

  def create_ticket
    Ticket.create! code: ticket_code, event: event, company_ticket_type: company_ticket_type
  end

  def create_ticket_credential_assignment
    find ticket
    create CredentialAssignment and
      assign ticket (polymorphic on credentiable)
      assign customer event profile
  end

  def create_customer_event_profile
    create customer event profile (event association only)
  end

  def create_gtag
    create Gtag
    assign customer_tag_uid
    assign tag serial number () # TODO: we have to send it, it is not currently being sent
    assign event
  end

  def create_gtag_credential_assignment
    find gtag
    create CredentialAssignment and
      assign gtag (polymorphic on credentiable)
      assign customer event profile
  end

  def create_customer_order; end

  def redeem_customer_order; end

  def redeem_gtag
    find gtag
    mark credential_redeemed as true
  end

  def redeem_ticket
    find ticket
    mark credential_redeemed as true
  end

  def initialize_balance; end

  def generate_monetray_transaction; end

end
