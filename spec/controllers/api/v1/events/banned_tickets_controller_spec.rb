require "spec_helper"

RSpec.describe Api::V1::Events::BannedTicketsController, type: :controller do
  subject { Api::V1::Events::BannedTicketsController.new }

  describe ".index" do
    it "calls .render_entities on base class with 'banned_ticket'" do
      expect(subject).to receive(:render_entities).with("banned_ticket").once
      subject.index
    end
  end
end
