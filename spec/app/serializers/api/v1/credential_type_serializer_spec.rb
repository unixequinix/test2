require "rails_helper"

RSpec.describe Api::V1::CredentialTypeSerializer, type: :serializer do
  context "Individual Resource Representation" do
    let(:resource) { build(:credential_type) }

    let(:serializer) { Api::V1::CredentialTypeSerializer.new(resource) }
    let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }

    subject { JSON.parse(serialization.to_json) }

    it "returns the catalog_items catalogable_id" do
      expect(subject["catalogable_id"]).to eq(resource.catalog_item.catalogable_id)
    end

    it "returns the catalog_items catalogable_type" do
      expect(subject["catalogable_type"]).to eq(resource.catalog_item.catalogable_type.downcase)
    end

    it "returns the memory_position as position" do
      expect(subject["position"]).to eq(resource.memory_position)
    end
  end
end
