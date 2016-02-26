# == Schema Information
#
# Table name: entitlements
#
#  id                   :integer          not null, primary key
#  entitlementable_id   :integer          not null
#  entitlementable_type :string           not null
#  memory_position      :integer          not null
#  type                 :string           default("simple"), not null
#  unlimited            :boolean          default(FALSE), not null
#  deleted_at           :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class Entitlement < ActiveRecord::Base
  belongs_to :entitlementable, polymorphic: true, touch: true

  validates :memory_position, :type, :unlimited, presence: true
end
