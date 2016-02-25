# == Schema Information
#
# Table name: catalog_item_packs
#
#  id              :integer          not null, primary key
#  pack_id         :integer          not null
#  catalog_item_id :integer          not null
#  amount          :integer
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class PackCatalogItem < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :pack
  belongs_to :catalog_item

  validates :amount, presence: true
end
