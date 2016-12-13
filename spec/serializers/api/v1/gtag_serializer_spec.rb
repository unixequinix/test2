require "spec_helper"

RSpec.describe Api::V1::GtagSerializer, type: :serializer do
  context "Individual Resource Representation" do
    let(:resource) { build(:gtag, customer: build(:customer)) }

    let(:serializer) { Api::V1::GtagSerializer.new(resource) }
    let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }

    subject { JSON.parse(serialization.to_json) }

    it "returns the customer associated" do
      expect(subject["customer"]).not_to be_nil
    end
  end
end
