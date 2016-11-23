# == Schema Information
#
# Table name: companies
#
#  access_token :string
#  created_at   :datetime         not null
#  name         :string           not null
#  updated_at   :datetime         not null
#

class Company < ActiveRecord::Base
  has_many :company_event_agreements
  has_many :events, through: :company_event_agreements, dependent: :restrict_with_error

  before_create :generate_access_token

  validates :name, presence: true

  def unassigned_events
    Event.where.not(id: events)
  end

  private

  def generate_access_token
    loop do
      self.access_token = SecureRandom.hex
      break unless self.class.exists?(access_token: access_token)
    end
  end
end
