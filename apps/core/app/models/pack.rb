# == Schema Information
#
# Table name: packs
#
#  id         :integer          not null, primary key
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Pack < ActiveRecord::Base
  acts_as_paranoid

  has_one :catalog_item, as: :catalogable, dependent: :destroy
  has_many :pack_catalog_items
  accepts_nested_attributes_for :catalog_item, allow_destroy: true
  accepts_nested_attributes_for :pack_catalog_items, allow_destroy: true
end
