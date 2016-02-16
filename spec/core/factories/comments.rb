FactoryGirl.define do
  factory :comment do
    commentable { |comment| comment.association(:ticket) }
    admin
    body  { ["word #{rand(10)}", "word #{rand(10)}", "word #{rand(10)}", "word #{rand(10)}", "word #{rand(10)}"].join }
  end
end
