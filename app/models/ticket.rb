# == Schema Information
#
# Table name: tickets
#
#  id                :integer          not null, primary key
#  ticket_type_id    :integer          not null
#  number            :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  deleted_at        :datetime
#  purchaser_email   :string
#  purchaser_name    :string
#  purchaser_surname :string
#  event_id          :integer          not null
#

class Ticket < ActiveRecord::Base
  default_scope { order(:id) }
  acts_as_paranoid

  # Associations
  belongs_to :event
  has_many :admissions, dependent: :restrict_with_error
  has_one :assigned_admission, -> { where(
    aasm_state: :assigned)}, class_name: 'Admission'
  has_many :customer_event_profiles, through: :admissions
  has_one :assigned_customer_event_profile, -> { where(
    admissions: { aasm_state: :assigned }) }, class_name: 'CustomerEventProfile'
  belongs_to :ticket_type
  has_many :comments, as: :commentable

  # Validations
  validates :number, :ticket_type, presence: true
  validates :number, uniqueness: true

end
