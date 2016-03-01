# == Schema Information
#
# Table name: banned_tickets
#
#  id         :integer          not null, primary key
#  ticket_id  :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

class BannedTicket < ActiveRecord::Base
  belongs_to :ticket
  validates :ticket_id, uniqueness: true
  validates :ticket_id, presence: true
end
