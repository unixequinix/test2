require "rails_helper"

RSpec.describe Api::V1::AccessSerializer, type: :serializer do
  context "Individual Resource Representation" do
    let(:resource) { build(:access) }
    let(:catalog_item) { resource.catalog_item }
    let(:entitlement) { resource.entitlement }

    let(:serializer) { Api::V1::AccessSerializer.new(resource) }
    let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }

    subject { JSON.parse(serialization.to_json) }

    it "returns the catalog_items description" do
      expect(subject["description"]).to eq(catalog_item.description)
    end

    it "returns the catalog_items name" do
      expect(subject["name"]).to eq(catalog_item.name)
    end

    it "returns the entitlements mode" do
      expect(subject["mode"]).to eq(entitlement.mode)
    end

    it "returns the entitlements position" do
      expect(subject["memory_position"]).to eq(entitlement.memory_position)
    end

    it "returns the entitlements memory_length" do
      expect(subject["memory_length"]).to eq(entitlement.memory_length.to_i)
    end

    it "returns the memory_length as an integer" do
      expect(subject["memory_length"]).to be_an(Integer)
    end
  end
end
