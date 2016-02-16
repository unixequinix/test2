# == Schema Information
#
# Table name: companies
#
#  id         :integer          not null, primary key
#  event_id   :integer          not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  token      :string
#

class Company < ActiveRecord::Base
  has_many :company_ticket_types, dependent: :restrict_with_error
  belongs_to :event

  # Hooks
  before_create :generate_token

  # Validations
  validates :name, :event_id, presence: true
  validates_uniqueness_of :name, scope: :event_id

  def generate_token
    loop do
      self.token = SecureRandom.hex
      break unless self.class.exists?(token: token)
    end
  end
end
