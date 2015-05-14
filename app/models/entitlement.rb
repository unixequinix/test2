# == Schema Information
#
# Table name: entitlements
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

class Entitlement < ActiveRecord::Base
  acts_as_paranoid

  # Associations
  has_many :entitlement_ticket_types, dependent: :destroy
  has_many :ticket_types, through: :entitlement_ticket_types, dependent: :destroy

  # Validations
  validates :name, presence: true

  # Select options with all the entitlements
  def self.form_selector
    all.map{ |entitlement| [entitlement.name, entitlement.id] }
  end
end
