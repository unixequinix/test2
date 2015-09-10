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

FactoryGirl.define do
  factory :claim_parameter do
    value "0.0"
    claim
    parameter
  end
end
