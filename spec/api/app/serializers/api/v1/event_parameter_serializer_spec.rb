require "rails_helper"

RSpec.describe Api::V1::EventParameterSerializer, type: :serializer do
  context "Individual Resource Representation" do
    let(:resource) { build(:event_parameter) }

    let(:serializer) { Api::V1::ParameterSerializer.new(resource) }
    let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }

    subject { JSON.parse(serialization.to_json) }

    it "returns the parameter name" do
      expect(subject["name"]).to eq(resource.parameter.name)
    end
  end
end
