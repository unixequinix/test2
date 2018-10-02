FactoryBot.define do
  factory :poke do
    sequence(:gtag_counter)
    sequence(:line_counter)
    operation { create(:credit_transaction, event: event) }
    date { Time.zone.now }
    event
    status_code { 0 }

    trait :as_purchase do
      before(:create) do |instance|
        instance.action = "purchase"
        instance.monetary_total_price = rand(100)
      end
    end

    trait :as_access do
      before(:create) do |instance|
        instance.action = "checkpoint"
        instance.access_direction = 1
      end
    end

    trait :as_sales do
      transient do
        credit { nil }
      end

      before(:create) do |instance, _evaluator|
        instance.action = "sale"
        instance.description = "product"
        instance.credit = instance.credit || instance.event.credit
        instance.credit_amount = -rand(100)
        instance.sale_item_unit_price = rand(100)
        instance.final_balance = rand(100)
        instance.sale_item_quantity = rand(5)
        instance.customer = create(:customer, event: instance.event)
        instance.station = instance.station || create(:station, event: instance.event, category: 'vendor')
        instance.product = create(:product, station: instance.station)
      end
    end

    trait :as_topups do
      before(:create) do |instance|
        instance.action = instance.action || "topup"
        instance.credit = instance.credit || instance.event.credit
        instance.payment_method = %w[card cash].sample
        instance.monetary_quantity = rand(5)
        instance.monetary_unit_price = rand(100)
        instance.monetary_total_price = instance.monetary_quantity * instance.monetary_unit_price
      end
    end

    trait :as_refunds do
      before(:create) do |instance|
        instance.action = "refund"
        instance.payment_method = %w[card cash].sample
        instance.monetary_quantity = rand(5)
        instance.monetary_unit_price = rand(100)
        instance.monetary_total_price = instance.monetary_quantity * instance.monetary_unit_price
      end
    end

    trait :as_record_credit_topups do
      transient do
        credit { nil }
        station { nil }
      end

      before(:create) do |instance, evaluator|
        instance.action = "topup"
        instance.credit = evaluator.credit || instance.event.credit
        instance.credit_amount = rand(100)
        instance.credit_name = instance.event.credit.name
        instance.sale_item_unit_price = rand(100)
        instance.final_balance = rand(100)
        instance.customer = create(:customer, event: instance.event)
        instance.station = evaluator.station || create(:station, event: instance.event, category: 'top_up_refund')
      end
    end

    trait :as_access do
      before(:create) do |instance|
        instance.action = "checkpoint"
        instance.catalog_item.id = 5
        instance.access_direction = 1
      end
    end

    trait :with_sale_items do
      transient do
        operation_transaction { nil }
        sale_item { nil }
      end

      before(:create) do |instance, evaluator|
        instance.id = evaluator.id
        instance.sale_item_quantity = evaluator.sale_item&.quantity
        instance.sale_item_unit_price = evaluator.sale_item&.standard_unit_price
        instance.line_counter = evaluator.sale_item&.id
        instance.action = evaluator.operation_transaction&.action
      end
    end
  end
end
