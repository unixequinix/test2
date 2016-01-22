# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  commentable_id   :integer          not null
#  commentable_type :string           not null
#  admin_id         :integer
#  body             :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

FactoryGirl.define do
  factory :comment do
    commentable { |comment| comment.association(:ticket) }
    admin
    body  { Faker::Lorem.words(5).join }
  end
end
