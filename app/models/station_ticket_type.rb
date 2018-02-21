class StationTicketType < ApplicationRecord
  belongs_to :station, touch: true
  belongs_to :ticket_type
end
