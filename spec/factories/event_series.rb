FactoryGirl.define do
  factory :event_serie do
    name 'Event Serie'

    trait :with_events do
      transient do
        associated_events nil
      end

      after(:create) do |event_serie, evaluator|
        event = evaluator.associated_events || create(:event)
        event_serie.events << event
      end
    end
  end
end
