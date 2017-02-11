# == Schema Information
#
# Table name: companies
#
#  access_token :string
#  name         :string           not null
#
# Indexes
#
#  index_companies_on_event_id  (event_id)
#
# Foreign Keys
#
#  fk_rails_b64f18cd7d  (event_id => events.id)
#

class Company < ActiveRecord::Base
  has_many :ticket_types

  belongs_to :event

  validates :name, presence: true
  validates :name, uniqueness: { scope: :event_id }

  def generate_access_token
    loop do
      self.access_token = SecureRandom.hex
      break unless Company.exists?(access_token: access_token)
    end
  end
end
