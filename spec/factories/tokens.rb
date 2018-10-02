FactoryBot.define do
  factory :token do |_param|
    event
    name "Token"
    value 1
    symbol "TK"

    before(:create) do |instance, _evaluator|
      pos = instance.event.currencies&.last&.position
      spendo = instance.event.currencies&.last&.spending_order

      instance.position = (pos.to_i + 1) || 1
      instance.spending_order = (spendo.to_i + 1) || 1
    end
  end
end
