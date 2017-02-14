require "spec_helper"

RSpec.describe Api::V1::TicketTypeSerializer, type: :serializer do
  context "Individual Resource Representation" do
    let(:resource) { build(:ticket_type) }

    let(:serializer) { Api::V1::TicketTypeSerializer.new(resource) }
    let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }

    subject { JSON.parse(serialization.to_json) }

    it "returns the comapny id" do
      expect(subject["company_id"]).to eq(resource.company.id)
    end

    it "returns the company name" do
      expect(subject["company_name"]).to eq(resource.company.name)
    end

    it "returns the company_code as ticket_type_ref" do
      expect(subject["ticket_type_ref"]).to eq(resource.company_code)
    end
  end
end
