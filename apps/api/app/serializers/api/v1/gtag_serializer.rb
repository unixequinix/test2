class Api::V1::GtagSerializer < Api::V1::BaseSerializer
  attributes :id, :tag_uid, :tag_serial_number, :credential_redeemed, :banned, :credential_type_id,
             :customer_id, :purchaser_first_name, :purchaser_last_name, :purchaser_email

  def credential_type_id
    object&.company_ticket_type&.credential_type_id
  end

  def customer_id
    object&.assigned_profile
  end

  def purchaser_first_name
    object&.purchaser&.first_name
  end

  def purchaser_last_name
    object&.purchaser&.last_name
  end

  def purchaser_email
    object&.purchaser&.email
  end
end
