require "rails_helper"

RSpec.describe Api::V1::Events::AccessesController, type: :controller do
  subject { Api::V1::Events::AccessesController.new }

  describe ".index" do
    it "calls .render_entities on base class with 'access'" do
      expect(subject).to receive(:render_entities).with("access").once
      subject.index
    end
  end
end
