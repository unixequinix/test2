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
  factory :credit do |_param|
    event
    sequence(:name) { |n| "Credit #{n}" }
    value 1
    symbol "C"

    before(:create) do |instance, _evaluator|
      pos = instance.event.currencies&.last&.position
      spendo = instance.event.currencies&.last&.spending_order

      instance.position = (pos.to_i + 1) || 1
      instance.spending_order = (spendo.to_i + 1) || 1
    end
  end
end
