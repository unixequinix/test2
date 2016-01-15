# == Schema Information
#
# Table name: claim_parameters
#
#  id           :integer          not null, primary key
#  value        :string           default(""), not null
#  claim_id     :integer          not null
#  parameter_id :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class ClaimParameter < ActiveRecord::Base
  # Association
  belongs_to :claim
  belongs_to :parameter

  # Validations
  validates :claim, presence: true
  validates :parameter, presence: true
  validates :value, presence: true
  validate :value_type

  # Scopes
  scope :full, lambda {
    joins(:parameter)
      .select("claim_parameters.*,
             parameters.group as group,
             parameters.name as name,
             parameters.category as category,
             parameters.data_type as data_type")
  }

  # Methods
  # -------------------------------------------------------

  def self.for_category(category, claim)
    full.where(claim: claim, parameters: { category: category })
  end

  private

  def value_type
    validator = Parameter::DATA_TYPES['string'][:validator]
    return unless validator
    return if value =~ validator
    errors.add(:value, "errors.parameters.incorrect_type.#{parameter.data_type}") 
  end
end
