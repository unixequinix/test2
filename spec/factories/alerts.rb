FactoryGirl.define do
  factory :alert do
    event nil
    user nil
    subject nil
    body "MyString"
  end
end
