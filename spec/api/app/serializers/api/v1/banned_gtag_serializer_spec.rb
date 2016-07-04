require "rails_helper"

RSpec.describe Api::V1::BannedGtagSerializer, type: :serializer do
  context "Individual Resource Representation" do
    let(:resource) { build(:gtag, banned: true) }

    let(:serializer) { Api::V1::BannedGtagSerializer.new(resource) }
    let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }

    subject { JSON.parse(serialization.to_json) }

    it "returns the banned gtag tag_uid" do
      expect(subject["reference"]).to eq(resource.tag_uid)
    end
  end
end
