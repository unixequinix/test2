require "spec_helper"

RSpec.describe Api::V1::TicketSerializer, type: :serializer do
  context "Individual Resource Representation" do
    let(:resource) { build(:ticket, customer: build(:customer)) }

    let(:serializer) { Api::V1::TicketSerializer.new(resource) }
    let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }

    subject { JSON.parse(serialization.to_json) }

    it "returns the customer associated" do
      expect(subject["customer"]).not_to be_nil
    end
  end
end
