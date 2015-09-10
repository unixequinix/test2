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

FactoryGirl.define do
  factory :event_parameter do
    transient do
      position_of_value [0,1,2].sample
    end
    value { [Faker::Lorem.word, Faker::Number.number(5), Faker::Number.decimal(2)][position_of_value]}
    event

    after :build do |event_parameter, evaluator|
      case evaluator.position_of_value
        when 0 then event_parameter.parameter = FactoryGirl.build(:parameter, data_type: "string" )
        when 1 then event_parameter.parameter = FactoryGirl.build(:parameter, data_type: "integer" )
        when 2 then event_parameter.parameter = FactoryGirl.build(:parameter, data_type: "currency" )
      end
    end
  end
end