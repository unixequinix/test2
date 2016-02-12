# == Schema Information
#
# Table name: companies
#
#  id         :integer          not null, primary key
#  event_id   :integer          not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Company < ActiveRecord::Base
  has_many :company_ticket_types
  belongs_to :event
end
