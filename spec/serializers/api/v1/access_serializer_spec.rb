require "spec_helper"

RSpec.describe Api::V1::AccessSerializer, type: :serializer do
  context "Individual Resource Representation" do
    let(:access) { build(:access) }

    let(:serializer) { Api::V1::AccessSerializer.new(access) }
    let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }

    subject { JSON.parse(serialization.to_json) }

    it "returns the catalog_items name" do
      expect(subject["name"]).to eq(access.name)
    end

    it "returns the accesses mode" do
      expect(subject["mode"]).to eq(access.mode)
    end

    it "returns the accesses position" do
      expect(subject["memory_position"]).to eq(access.memory_position)
    end

    it "returns the accesses memory_length" do
      expect(subject["memory_length"]).to eq(access.memory_length.to_i)
    end

    it "returns the memory_length as an integer" do
      expect(subject["memory_length"]).to be_an(Integer)
    end
  end
end
