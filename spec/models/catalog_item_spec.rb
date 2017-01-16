# == Schema Information
#
# Table name: catalog_items
#
#  initial_amount  :integer
#  max_purchasable :integer
#  memory_length   :integer          default(1)
#  memory_position :integer
#  min_purchasable :integer
#  mode            :string
#  name            :string
#  step            :integer
#  type            :string           not null
#  value           :decimal(8, 2)    default(1.0), not null
#
# Indexes
#
#  index_catalog_items_on_event_id                      (event_id)
#  index_catalog_items_on_memory_position_and_event_id  (memory_position,event_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_6d2668d4ae  (event_id => events.id)
#

require "spec_helper"

RSpec.describe CatalogItem, type: :model do
  subject { build(:catalog_item) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  it "validates step is greater than 1" do
    subject.step = 0
    expect(subject).not_to be_valid
  end

  describe ".credits" do
    it "returns 0" do
      expect(subject.credits).to eq(0)
    end
  end
end
