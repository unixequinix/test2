# == Schema Information
#
# Table name: entitlements
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Entitlement < ActiveRecord::Base

  # Associations
  has_and_belongs_to_many :ticket_types

  # Validations
  validates :name, presence: true
end
