# == Schema Information
#
# Table name: credential_types
#
#  id              :integer          not null, primary key
#  catalog_item_id :integer          not null
#  memory_position :integer          not null
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

FactoryGirl.define do
  factory :credential_type do
   catalog_item
  end
end
