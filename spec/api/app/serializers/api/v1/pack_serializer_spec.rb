require "rails_helper"

RSpec.describe Api::V1::PackSerializer, type: :serializer do
  context "Individual Resource Representation" do
    let(:resource_access) { create(:catalog_item, :with_access_pack).catalogable }
    let(:resource_credits) { create(:catalog_item, :with_credit_pack).catalogable }

    let(:serializer_access) { Api::V1::PackSerializer.new(resource_access) }
    let(:serialization_access) { ActiveModelSerializers::Adapter.create(serializer_access) }

    let(:serializer_credits) { Api::V1::PackSerializer.new(resource_credits) }
    let(:serialization_credits) { ActiveModelSerializers::Adapter.create(serializer_credits) }

    let(:subject_access) { JSON.parse(serialization_access.to_json) }
    let(:subject_credit) { JSON.parse(serialization_credits.to_json) }

    it "returns the catalog_items name" do
      expect(subject_access["name"]).to eq(resource_access.catalog_item.name)
    end

    it "return the catalog_items description" do
      expect(subject_access["description"]).to eq(resource_access.catalog_item.description)
    end

    it "returns accesses only when available" do
      expect(subject_access["accesses"]).not_to be_empty
      expect(subject_credit["accesses"]).to be_empty
    end

    it "returns credits only when available" do
      expect(subject_credit["credits"]).not_to be_nil
      expect(subject_access["credits"]).to be_nil
    end

    describe ".accesses" do
      it "returns the id and the amount of each access" do
        selected = resource_access.pack_catalog_items.select do |pack_item|
          pack_item.catalog_item.catalogable_type == "Access"
        end
        accesses = selected.map { |a| { id: a.catalog_item.catalogable_id, amount: a.amount } }

        expect(subject_access["accesses"]).to eq(accesses.as_json)
      end
    end

    describe ".credits" do
      it "returns the total amount of credits" do
        selected = resource_credits.pack_catalog_items.select do |pack_item|
          pack_item.catalog_item.catalogable_type == "Credit"
        end
        total = selected.map(&:amount).inject(:+)

        expect(subject_credit["credits"].to_d).to eq(total)
      end
    end
  end
end
