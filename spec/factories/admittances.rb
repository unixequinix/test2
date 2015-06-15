FactoryGirl.define do
  factory :admittance do
    admission
    ticket
    aasm_state 'assigned'
  end
end
