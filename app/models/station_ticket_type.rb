class StationTicketType < ApplicationRecord
  belongs_to :station
  belongs_to :ticket_type
end
