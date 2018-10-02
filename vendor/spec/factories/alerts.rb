FactoryBot.define do
  factory :alert do
    event { nil }
    subject { nil }
    body { "MyString" }
  end
end
