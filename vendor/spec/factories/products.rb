FactoryBot.define do
  factory :product do
    station
    sequence(:name) { |i| "Product #{i}" }
    price { 99 }
    sequence(:position)

    before(:create) do |instance, evaluator|
      instance.station = instance.station
      instance.prices = { evaluator.station.event.credit.id.to_s => { 'price' => 99 } }
    end
  end
end
