# == Schema Information
#
# Table name: ticket_blacklists
#
#  id         :integer          not null, primary key
#  ticket_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TicketBlacklist < ActiveRecord::Base
  belongs_to :ticket
end
