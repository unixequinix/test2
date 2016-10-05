# == Schema Information
#
# Table name: parameters
#
#  id          :integer          not null, primary key
#  name        :string           not null
#  data_type   :string           not null
#  category    :string           not null
#  group       :string           not null
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Parameter < ActiveRecord::Base
  DATA_TYPES = {
    "string" => { default: "-", validator: /.+/ },
    "currency" => { default: "0.0", validator: /^\d+(\.\d{2})?/ },
    "integer" => { default: "0", validator: /^\d+/ },
    "boolean" => { default: "false", validator: /true|false/ }
  }.freeze

  # Associations
  has_many :event_parameters
  has_many :events, through: :event_parameters

  # Validations
  validates :name, :category, :group, :data_type, presence: true
  validates :name, uniqueness: { scope: [:group, :category] }

  # Methods
  # -------------------------------------------------------

  def self.default_value_for(data_type)
    data_config = Parameter::DATA_TYPES[data_type]
    if data_config
      data_config[:default]
    else
      ""
    end
  end
end
