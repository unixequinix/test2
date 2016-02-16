class Api::V1::TicketSerializer < Api::V1::BaseSerializer
  attributes :id, :preevent_product_id, :reference, :credential_redeemed

  def attributes(*args)
    hash = super
    hash[:customer_id] = customer_id if object.credential_assignments.first
    hash
  end

  def preevent_product_id
    object.company_ticket_type.preevent_product_id
  end

  def customer_id
    object.credential_assignments.first.customer_event_profile_id
  end

  def reference
    object.code
  end
end
