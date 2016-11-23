require "spec_helper"

RSpec.describe Api::V1::Events::CreditsController, type: :controller do
  subject { Api::V1::Events::CreditsController.new }

  describe ".index" do
    it "calls .render_entities on base class with 'credit'" do
      expect(subject).to receive(:render_entities).with("credit").once
      subject.index
    end
  end
end
