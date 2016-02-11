FactoryGirl.define do
  factory :comment do
    commentable { |comment| comment.association(:ticket) }
    admin
    body  { Faker::Lorem.words(5).join }
  end
end
