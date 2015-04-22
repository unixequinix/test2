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
  has_many :ticket_types

  # Validations
  validates :name, presence: true

  # Select options with all the entitlements
  def self.form_selector
    all.map{ |entitlement| [entitlement.name, entitlement.id] }
  end
end
