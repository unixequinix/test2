class Companies::Api::V1::GtagSerializer < Companies::Api::V1::BaseSerializer
  attributes :id, :tag_uid, :purchaser_first_name, :purchaser_last_name, :purchaser_email,
             :ticket_type_id

  def ticket_type_id
    object.company_ticket_type_id
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
