require "rails_helper"

RSpec.describe Api::V1::CompanyTicketTypeSerializer, type: :serializer do
  context "Individual Resource Representation" do
    let(:resource) { build(:company_ticket_type) }

    let(:serializer) { Api::V1::CompanyTicketTypeSerializer.new(resource) }
    let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }

    subject { JSON.parse(serialization.to_json) }

    it "returns the agreements comapny id" do
      expect(subject["company_id"]).to eq(resource.company_event_agreement.company.id)
    end

    it "returns the agreements company name" do
      expect(subject["company_name"]).to eq(resource.company_event_agreement.company.name)
    end

    it "returns the company_code as company_ticket_type_ref" do
      expect(subject["company_ticket_type_ref"]).to eq(resource.company_code)
    end
  end
end
