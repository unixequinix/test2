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

RSpec.describe Credit, type: :model do
  subject { build(:credit) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  it "validates initial_amount against max_purchasable" do
    subject.initial_amount = subject.max_purchasable + 1
    expect(subject).not_to be_valid
  end

  it "validates max_purchasable against initial_amount" do
    subject.max_purchasable = subject.initial_amount - 1
    expect(subject).not_to be_valid
  end

  describe ".credits" do
    it "returns 1" do
      expect(subject.credits).to eq(1)
    end
  end

  describe ".set_customer_portal_price" do
    let(:event) { create(:event) }

    it "sets the price to whatever the value of the credit is after save" do
      event.initial_setup!
      credit = event.credit
      credit.update(value: 4.5)
      expect(event.portal_station.station_catalog_items.find_by(catalog_item: credit).price).to eq(4.5)
    end
  end
end
