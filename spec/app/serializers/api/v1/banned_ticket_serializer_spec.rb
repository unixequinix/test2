require "rails_helper"

RSpec.describe Api::V1::BannedTicketSerializer, type: :serializer do
  context "Individual Resource Representation" do
    let(:resource) { build(:ticket, banned: true) }

    let(:serializer) { Api::V1::BannedTicketSerializer.new(resource) }
    let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }

    subject { JSON.parse(serialization.to_json) }

    it "returns the banned ticket code as reference" do
      expect(subject["reference"]).to eq(resource.code)
    end
  end
end
