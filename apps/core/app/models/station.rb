# == Schema Information
#
# Table name: stations
#
#  id              :integer          not null, primary key
#  event_id        :integer          not null
#  station_type_id :integer          not null
#  name            :string           not null
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Station < ActiveRecord::Base
  belongs_to :station_type
  has_many :operator_permisions
  has_many :operators, through: :operator_permisions, class_name: "Operator"
end
