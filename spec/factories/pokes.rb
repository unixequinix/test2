FactoryBot.define do
  factory :poke do
    sequence(:gtag_counter)
    sequence(:line_counter)
    operation { create(:credit_transaction, event: event) }
    source "onsite"
    date { Time.zone.now }
    action "topup"
    event
    status_code 0

    trait :with_sale_items do
      transient do
        operation_transaction nil
        sale_item nil
      end

      before(:create) do |instance, evaluator|
        instance.id = evaluator.id
        instance.is_alcohol = evaluator.sale_item.product&.is_alcohol
        instance.sale_item_quantity = evaluator.sale_item.quantity
        instance.sale_item_unit_price = evaluator.sale_item.standard_unit_price
        instance.line_counter = evaluator.sale_item.id
        instance.action = evaluator.operation_transaction.action
      end
    end
  end
end
