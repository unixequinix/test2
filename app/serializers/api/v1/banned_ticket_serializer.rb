class Api::V1::BannedTicketSerializer < Api::V1::BaseSerializer
  attributes :id, :reference

  def reference
    object.code
  end
end