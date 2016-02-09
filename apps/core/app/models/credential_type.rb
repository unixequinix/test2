# == Schema Information
#
# Table name: credential_types
#
#  id              :integer          not null, primary key
#  memory_position :integer          not null
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class CredentialType < ActiveRecord::Base
  acts_as_paranoid
  acts_as_list column: :memory_position

  has_one :preevent_item, as: :purchasable, dependent: :destroy
  accepts_nested_attributes_for :preevent_item, allow_destroy: true

  # Validations
  validates :preevent_item, presence: true

end
