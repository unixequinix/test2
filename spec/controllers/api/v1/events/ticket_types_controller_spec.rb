require "spec_helper"

RSpec.describe Api::V1::Events::TicketTypesController, type: :controller do
  subject { Api::V1::Events::TicketTypesController.new }

  describe ".index" do
    it "calls .render_entities on base class with 'ticket_type'" do
      expect(subject).to receive(:render_entities).with("ticket_type").once
      subject.index
    end
  end
end
