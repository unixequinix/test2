# == Schema Information
#
# Table name: credential_types
#
#  id         :integer          not null, primary key
#  positon    :integer          default(0), not null
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CredentialType < ActiveRecord::Base
  acts_as_paranoid

  has_many :preevent_product_units, as: :purchasable, dependent: :destroy

  # Validations
  validates :position, presence: true
end
