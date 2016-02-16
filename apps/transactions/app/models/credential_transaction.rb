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

  def self.pre_process(atts)
    atts.each { |key, value| atts[key] = value.upcase if key.to_s.end_with?("uid") }
  end

  def create_ticket
    # create Ticket with:
    # => ticket_code
    # => event
    # => company_ticket_type (
    # => retreieved from decoding ticket_code#last and searching for
    #    company_code within companies table)
    Ticket.create! code: ticket_code,
                   event: event,
                   company_ticket_type: company_ticket_type
  end

  def create_customer_event_profile
    # create CustomerEventProfile with:
    # => event
    CustomerEventProfile.create!(event: event)
  end

  def create_ticket_credential_assignment
    # create CredentialAssignment with:
    # => assign ticket (polymorphic on credentiable)
    # => assign customer event profile

    CredentialAssignment.create! event: event,
                                 credentiable: ticket,
                                 customer_event_profile: customer_event_profile
  end

  def create_gtag
    # create Gtag with:
    # => customer_tag_uid
    # => event
    Gtag.create!(tag_uid: customer_tag_uid, event: event)
  end

  def create_gtag_credential_assignment
    # create CredentialAssignment with:
    # => assign gtag (polymorphic on credentiable)
    # => assign customer event profile
    gtag = Gtag.find_by(event: event, tag_uid: customer_tag_uid)
    CredentialAssignment.create! event: event,
                                 credentiable: gtag,
                                 customer_event_profile: customer_event_profile
  end

  def redeem_gtag
    # find gtag by tag_UID
    # mark credential_redeemed as true
    Gtag.find_by(event: event, tag_uid: customer_tag_uid).update!(credential_redeemed: true)
  end

  def redeem_ticket
    # mark credential_redeemed as true on Ticket
    ticket.update!(credential_redeemed: true)
  end

  def create_customer_order; end

  def redeem_customer_order; end

  def initialize_balance; end

  def generate_monetray_transaction; end
end
