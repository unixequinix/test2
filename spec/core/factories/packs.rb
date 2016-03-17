# == Schema Information
#
# Table name: packs
#
#  id                  :integer          not null, primary key
#  catalog_items_count :integer          default(0), not null
#  deleted_at          :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

FactoryGirl.define do
  factory :pack do
    trait :with_credit do
      after :build do |pack|
        catalog_item = create(:catalog_item, catalogable: pack)
        pack.pack_catalog_items.build(catalog_item: build(:credit_catalog_item), amount: 2)
      end
    end
    trait :with_access do
      after :build do |pack|
        catalog_item = create(:catalog_item, catalogable: pack)
        pack.pack_catalog_items.build(catalog_item: build(:access_catalog_item), amount: 2)
      end
    end
    trait :with_voucher do
      after :build do |pack|
        catalog_item = create(:catalog_item, catalogable: pack)
        pack.pack_catalog_items.build(catalog_item: build(:voucher_catalog_item), amount: 2)
      end
    end
  end
end
