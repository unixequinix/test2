# == Schema Information
#
# Table name: admissions
#
#  id          :integer          not null, primary key
#  customer_id :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  event_id    :integer          default(1), not null
#

class Admission < ActiveRecord::Base
  # Associations
  belongs_to :customer
  belongs_to :event
  has_many :admittances
  has_one :assigned_admittance, -> { where(aasm_state: :assigned) },
    class_name: "Admittance"

  # Validations
  validates :customer, :event, presence: true

  # Scopes
  scope :for_event, -> (event) { where(event: event) }
end
