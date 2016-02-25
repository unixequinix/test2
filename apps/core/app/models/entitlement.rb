# == Schema Information
#
# Table name: entitlements
#
#  id                   :integer          not null, primary key
#  entitlementable_id   :integer          not null
#  entitlementable_type :string           not null
#  memory_position      :integer
#  unlimited            :boolean
#  deleted_at           :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class Entitlement < ActiveRecord::Base
  belongs_to :entitlementable, polymorphic: true, touch: true
end
