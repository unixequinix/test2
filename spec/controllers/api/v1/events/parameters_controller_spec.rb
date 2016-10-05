require "rails_helper"

RSpec.describe Api::V1::Events::ParametersController, type: :controller do
  subject { Api::V1::Events::ParametersController.new }

  describe ".index" do
    it "calls .render_entities on base class with 'event_parameter'" do
      expect(subject).to receive(:render_entities).with("event_parameter").once
      subject.index
    end
  end
end
