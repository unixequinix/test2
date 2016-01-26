# == Schema Information
#
# Table name: banned_tickets
#
#  id         :integer          not null, primary key
#  ticket_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class BannedTicket < ActiveRecord::Base
  belongs_to :ticket
  validates :ticket_id, uniqueness: true
end
