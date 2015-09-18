# == Schema Information
#
# Table name: gtags
#
#  id                :integer          not null, primary key
#  tag_uid           :string           not null
#  tag_serial_number :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  deleted_at        :datetime
#  event_id          :integer          not null
#

class Gtag < ActiveRecord::Base

  STANDARD       = 'standard'
  CARD  = 'card'
  SIMPLE = 'simple'

  # Type of the gtags
  FORMATS = [STANDARD, CARD, SIMPLE]

  before_validation :upcase_gtag!
  default_scope { order(:id) }
  acts_as_paranoid

  # Associations
  belongs_to :event
  has_many :gtag_registrations, dependent: :restrict_with_error
  has_one :assigned_gtag_registration, ->{ where(aasm_state: :assigned) }, class_name: "GtagRegistration"
  has_many :customer_event_profiles, through: :gtag_registrations
  has_one :assigned_customer_event_profile, ->{ where(gtag_registrations: {aasm_state: :assigned}) }, class_name: "CustomerEventProfile"
  has_one :gtag_credit_log
  has_one :refund
  has_many :claims
  has_one :completed_claim, ->{ where(aasm_state: :completed) }, class_name: "Claim"
  has_many :comments, as: :commentable

  accepts_nested_attributes_for :gtag_credit_log, allow_destroy: true

  # Validations
  validates_uniqueness_of :tag_uid, scope: :event_id
  validates :tag_uid, :tag_serial_number, presence: true

  # Scope
  scope :selected_data, -> (event_id) {
    joins("LEFT OUTER JOIN gtag_credit_logs ON gtag_credit_logs.gtag_id = gtags.id")
    .select("gtags.*, gtag_credit_logs.amount")
    .where(event: event_id)
  }

  private

  def upcase_gtag!
    self.tag_uid.upcase!
    self.tag_serial_number.upcase!
  end
end
