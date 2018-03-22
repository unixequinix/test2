FactoryBot.define do
  factory :device_transaction do
    event
    device
    initialization_type "LITE_INITIALIZATION"
    action "device_initialization"
    server_transactions 0

    trait :with_device do
      transient do
        device nil
      end

      before(:create) do |device_transaction, evaluator|
        transactions = DeviceTransaction.where(device: evaluator.device)
        device_transaction.event_id = device_transaction.event.id
        device_transaction.device_id = evaluator.device.id
        device_transaction.server_transactions = transactions.count
        device_transaction.number_of_transactions = transactions.count + 1
        device_transaction.counter = transactions.count + 1
      end
    end
  end
end
