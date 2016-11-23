require "spec_helper"

RSpec.describe Api::V1::EventSerializer, type: :serializer do
  context "Individual Resource Representation" do
    let(:resource) { build(:event) }

    let(:serializer) { Api::V1::EventSerializer.new(resource) }
    let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }

    subject { JSON.parse(serialization.to_json) }

    it "returns the correct staging_start" do
      staging_start = Time.zone.parse(subject["staging_start"]).strftime("%d-%m-%Y %h:%m:%s")
      expected = (resource.start_date - 7.days).strftime("%d-%m-%Y %h:%m:%s")
      expect(staging_start).to eq(expected)
    end

    it "returns the correct staging_end" do
      staging_end = Time.zone.parse(subject["staging_end"]).strftime("%d-%m-%Y %h:%m:%s")
      expected = (resource.end_date + 7.days).strftime("%d-%m-%Y %h:%m:%s")
      expect(staging_end).to eq(expected)
    end
  end
end
