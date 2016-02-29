# == Schema Information
#
# Table name: companies
#
#  id           :integer          not null, primary key
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  access_token :string
#  deleted_at   :datetime
#

class Company < ActiveRecord::Base
  acts_as_paranoid

  has_many :company_event_agreements
  has_many :events, through: :company_event_agreements, dependent: :restrict_with_error

  # Hooks
  before_create :generate_access_token

  # Validations
  validates :name, presence: true

  def unassigned_events
    Event.where("id NOT IN (SELECT event_id
                   FROM company_event_agreements
                   WHERE company_id = #{id})")
  end

  private

  def generate_access_token
    loop do
      self.access_token = SecureRandom.hex
      break unless self.class.exists?(access_token: access_token)
    end
  end
end
