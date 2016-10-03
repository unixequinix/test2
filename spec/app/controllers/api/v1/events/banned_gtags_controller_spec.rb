require "rails_helper"

RSpec.describe Api::V1::Events::BannedGtagsController, type: :controller do
  subject { Api::V1::Events::BannedGtagsController.new }

  describe ".index" do
    it "calls .render_entities on base class with 'banned_gtag'" do
      expect(subject).to receive(:render_entities).with("banned_gtag").once
      subject.index
    end
  end
end
