FactoryGirl.define do
  factory :sale_item do |_param|
    product
    credit_transaction
    quantity { rand(1..5) }
    unit_price { rand(1..10) }
  end
end
