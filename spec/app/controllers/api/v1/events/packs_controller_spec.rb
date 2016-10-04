require "rails_helper"

RSpec.describe Api::V1::Events::PacksController, type: :controller do
  subject { Api::V1::Events::PacksController.new }

  describe ".index" do
    it "calls .render_entities on base class with 'pack'" do
      expect(subject).to receive(:render_entities).with("pack").once
      subject.index
    end
  end
end
