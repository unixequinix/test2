# == Schema Information
#
# Table name: credits
#
#  id         :integer          not null, primary key
#  standard   :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#  value      :decimal(8, 2)    default(1.0), not null
#  currency   :string           not null
#

FactoryBot.define do
  factory :virtual_credit do |_param|
    event
    name "Virtual"
    value 1
    symbol "V"
  end
end
