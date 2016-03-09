class Api::V1::TicketSerializer < Api::V1::BaseSerializer
  cache key: 'ticket', expires_in: 3.hours
  attributes :id, :reference, :credential_redeemed, :credential_type_id, :customer_id,
    :purchaser_first_name, :purchaser_last_name, :purchaser_email
end
