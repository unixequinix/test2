require "rails_helper"

RSpec.describe Api::V1::CreditSerializer, type: :serializer do
  context "Individual Resource Representation" do
    let(:resource) { build(:credit) }

    let(:serializer) { Api::V1::CreditSerializer.new(resource) }
    let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }

    subject { JSON.parse(serialization.to_json) }

    it "returns the catalog_items description" do
      expect(subject["description"]).to eq(resource.catalog_item.description)
    end

    it "returns the catalog_items name" do
      expect(subject["name"]).to eq(resource.catalog_item.name)
    end
  end
end