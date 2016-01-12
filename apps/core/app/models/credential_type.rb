# == Schema Information
#
# Table name: credential_types
#
#  id         :integer          not null, primary key
#  position   :integer          default(0), not null
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CredentialType < ActiveRecord::Base
  acts_as_paranoid

  has_one :preevent_item, as: :purchasable, dependent: :destroy
  accepts_nested_attributes_for :preevent_item, allow_destroy: true

  # Validations
  validates :position, presence: true
  validates :preevent_item, presence: true
end
