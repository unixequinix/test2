class Api::V1::GtagSerializer < Api::V1::BaseSerializer
  attributes :id, :tag_uid, :tag_serial_number,
             :credential_redeemed

  def attributes(*args)
    hash = super
    t_type = object.company_ticket_type
    id = t_type && t_type.preevent_product_id
    hash[:preevent_product_id] = id if id
    hash[:customer_id] = customer_id if object.credential_assignments.first
    hash
  end

  def customer_uid
    object.credential_assignments.first.customer_event_profile_id
  end
end
