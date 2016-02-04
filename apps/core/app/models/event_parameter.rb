# == Schema Information
#
# Table name: event_parameters
#
#  id           :integer          not null, primary key
#  value        :string           default(""), not null
#  event_id     :integer          not null
#  parameter_id :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class EventParameter < ActiveRecord::Base
  # Association
  belongs_to :event
  belongs_to :parameter

  # Validations
  validates :event, presence: true
  validates :parameter, presence: true
  validates :value, presence: true
  validate :value_type

  # Scopes
  scope :full, lambda {
    joins(:parameter)
      .select("event_parameters.*,
             parameters.group as group,
             parameters.name as name,
             parameters.category as category,
             parameters.data_type as data_type")
  }

  scope :with_event, lambda { |event| includes(:parameter).where(event: event) }

  # Methods
  # -------------------------------------------------------

  def self.for_category(category, event)
    full.where(event: event, parameters: { category: category })
  end

  private

  def value_type
    validator = Parameter::DATA_TYPES[parameter.data_type][:validator]
    return unless validator
    return if value =~ validator
    errors.add(:value, "errors.parameters.incorrect_type.#{parameter.data_type}")
  end
end
